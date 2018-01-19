pcall(require, "kong.plugins.openid-connect.env")


local configuration = require "kong.openid-connect.configuration"
local keys          = require "kong.openid-connect.keys"
local hash          = require "kong.openid-connect.hash"
local codec         = require "kong.openid-connect.codec"
local timestamp     = require "kong.tools.timestamp"
local utils         = require "kong.tools.utils"
local singletons    = require "kong.singletons"


local concat        = table.concat
local ipairs        = ipairs
local json          = codec.json
local type          = type
local pcall         = pcall
local log           = ngx.log
local null          = ngx.null
local time          = ngx.time
local encode_base64 = ngx.encode_base64
local sub           = string.sub
local tonumber      = tonumber


local NOTICE        = ngx.NOTICE
local DEBUG         = ngx.DEBUG
local ERR           = ngx.ERR


local cache_get, cache_key
do
  -- TODO: this check sucks but it is good enough now, as this supports only 0.10.x and >= 0.11.x
  local ok, cache = pcall(require, "kong.tools.database_cache")
  if ok then
    -- 0.10.x
    cache_get = function(key, opts, func, ...)
      local ttl
      if type(opts) == "table" then
        ttl = tonumber(opts.ttl)

      else
        ttl = tonumber(opts)
      end

      return cache.get_or_set(key, ttl, func, ...)
    end

    cache_key = function(key, entity)
      if entity then
        return entity .. ":" .. key
      end

      return key
    end

  else
    -- 0.11.x
    cache_get = function(key, opts, func, ...)
      local options
      if type(opts) == "number" then
        options = { ttl = opts }

      elseif type(opts) == "table" then
        options = opts
      end

      return singletons.cache:get(key, options, func, ...)
    end

    cache_key = function(key, entity)
      if entity then
        return singletons.dao[entity]:cache_key(key)
      end

      return key
    end
  end
end


local function init_worker()
  local cache = singletons.cache
  singletons.worker_events.register(function(data)
    log(DEBUG, "[openid-connect] consumer updated, invalidating cache")

    local old_entity = data.old_entity
    if old_entity then
      if old_entity.custom_id and old_entity.custom_id ~= null and old_entity.custom_id ~= "" then
        cache:invalidate(cache_key("custom_id:" .. old_entity.custom_id, "consumers"))
      end

      if old_entity.username and old_entity.username ~= null and old_entity.username ~= "" then
        cache:invalidate(cache_key("username:" .. old_entity.username,  "consumers"))
      end
    end

    local entity = data.entity
    if entity then
      if entity.custom_id and entity.custom_id ~= null and entity.custom_id ~= "" then
        cache:invalidate(cache_key("custom_id:" .. entity.custom_id, "consumers"))
      end

      if entity.username and entity.username ~= null and entity.username ~= "" then
        cache:invalidate(cache_key("username:" .. entity.username,  "consumers"))
      end
    end
  end, "crud", "consumers")
end


local function normalize_issuer(issuer)
  if sub(issuer, -1) == "/" then
    return sub(issuer, 1, #issuer - 1)
  end

  return issuer
end


local issuers = {}


function issuers.init(conf)
  local issuer = normalize_issuer(conf.issuer)

  log(NOTICE, "[openid-connect] loading openid connect configuration for ", issuer, " from database")

  local results = singletons.dao.oic_issuers:find_all { issuer = issuer }
  if results and results[1] then
    return {
      issuer        = issuer,
      configuration = results[1].configuration,
      keys          = results[1].keys,
      secret        = results[1].secret,
    }
  end

  log(NOTICE, "[openid-connect] loading openid connect configuration for ", issuer, " using discovery")

  local opts = {
    http_version = conf.http_version               or 1.1,
    ssl_verify   = conf.ssl_verify == nil and true or conf.ssl_verify,
    timeout      = conf.timeout                    or 10000,
  }

  local claims, err = configuration.load(issuer, opts)
  if not claims then
    log(ERR, "[openid-connect] loading openid connect configuration for ", issuer, " using discovery failed with ", err)
    return nil
  end

  local cdec
  cdec, err = json.decode(claims)
  if not cdec then
    log(ERR, err)
    return nil
  end

  local jwks_uri = cdec.jwks_uri
  local jwks
  if jwks_uri then
    log(NOTICE, "[openid-connect] loading openid connect jwks from ", jwks_uri)

    jwks, err = keys.load(jwks_uri, opts)
    if not jwks then
      log(ERR, "[openid-connect] loading openid connect jwks from ", jwks_uri, " failed with ", err)
      return nil
    end

  elseif cdec.jwks and cdec.jwks.keys then
    jwks, err = json.encode(cdec.jwks.keys)
    if not jwks then
      log(ERR, "[openid-connect] unable to encode jwks received as part of the ", issuer, " discovery document (", err , ")")
    end
  end

  local secret = sub(encode_base64(utils.get_rand_bytes(32)), 1, 32)

  local data = {
    issuer        = issuer,
    configuration = claims,
    keys          = jwks,
    secret        = secret,
  }

  data, err = singletons.dao.oic_issuers:insert(data)
  if not data then
    log(ERR, "[openid-connect] unable to store issuer ", issuer, " discovery documents in database (", err , ")")
    return nil
  end

  return data
end


function issuers.load(conf)
  local issuer = normalize_issuer(conf.issuer)
  local key    = cache_key(issuer, "oic_issuers")
  return cache_get(key, nil, issuers.init, conf)
end


local consumers = {}


function consumers.init(subject, key)
  if not subject or subject == "" then
    return nil, "openid connect is unable to load consumer by a missing subject"
  end

  local result, err

  if key == "id" then
    log(NOTICE, "[openid-connect] openid connect is loading consumer by id using " .. subject)
    result, err = singletons.dao.consumers:find { id = subject }
    if type(result) == "table" then
      return result
    end

  else
    log(NOTICE, "[openid-connect] openid connect is loading consumer by " .. key .. " using " .. subject)
    result, err = singletons.dao.consumers:find_all { [key] = subject }
    if type(result) == "table" and type(result[1]) == "table" then
      return result[1]
    end
  end

  return nil, err
end


function consumers.load(subject, anon, consumer_by)
  local cons
  if anon then
    cons = { "id" }

  elseif consumer_by then
    cons = consumer_by

  else
    cons = { "custom_id" }
  end

  for _, field_name in ipairs(cons) do
    local key

    if field_name == "id" then
      key = cache_key(subject, "consumers")

    else
      key = cache_key(field_name .. ":" .. subject, "consumers")
    end

    local consumer, err = cache_get(key, nil, consumers.init, subject, field_name)
    if consumer then
      return consumer
    end

    if err then
      log(NOTICE, "[openid-connect] failed to load consumer (" .. err .. ")")
    end
  end

  return nil
end


local oauth2 = {}


function oauth2.credential(credential_id)
  return singletons.dao.oauth2_credentials:find { id = credential_id }
end


function oauth2.consumer(consumer_id)
  return singletons.dao.consumers:find { id = consumer_id }
end


function oauth2.init(access_token)
  log(NOTICE, "[openid-connect] loading kong oauth2 token from database")
  local credentials, err = singletons.dao.oauth2_tokens:find_all { access_token = access_token }

  if err then
    return nil, err
  end

  if #credentials > 0 then
    return credentials[1]
  end

  return credentials
end


function oauth2.load(access_token)
  local key = cache_key(access_token, "oauth2_tokens")
  local token, err = cache_get(key, nil, oauth2.init, access_token)
  if not token then
    return nil, err
  end

  if not token.access_token or token.access_token ~= access_token then
    return nil, "kong oauth access token was not found"
  end

  if token.expires_in > 0 then
    local now = timestamp.get_utc()
    if now - token.created_at > (token.expires_in * 1000) then
      return nil, "kong access token is invalid or has expired"
    end
  end

  local credential
  local credential_cache_key = cache_key(token.credential_id, "oauth2_credentials")
  credential, err = cache_get(credential_cache_key, nil, oauth2.credential, token.credential_id)

  if not credential then
    return nil, err
  end

  local consumer
  local consumer_cache_key = cache_key(credential.consumer_id, "consumers")
  consumer, err = cache_get(consumer_cache_key, nil, oauth2.consumer, credential.consumer_id)

  if not consumer then
    return nil, err
  end

  return token, credential, consumer
end


local introspection = {}


function introspection.init(o, access_token, endpoint)
  log(NOTICE, "[openid-connect] introspecting access token with identity provider")
  local introspected = o.token:introspect(access_token, "access_token", {
    introspection_endpoint = endpoint
  })

  local expires_in

  if type(introspected) == "table" then
    if introspected.expires_in then
      expires_in = tonumber(introspected.expires_in)
    end

    if not expires_in then
      if introspected.exp then
        local exp = tonumber(introspected.exp)
        if exp then
          expires_in = exp - time()
        end
      end
    end
  end

  if expires_in and expires_in < 0 then
    expires_in = nil
  end

  return introspected, nil, expires_in
end


function introspection.load(o, access_token, endpoint, ttl)
  local iss = o.configuration.issuer
  local key = cache_key(iss .. "#introspection=" .. access_token)

  return cache_get(key, ttl, introspection.init, o, access_token, endpoint)
end


local tokens = {}


function tokens.init(o, args)
  log(NOTICE, "[openid-connect] loading tokens from the identity provider")
  local toks, err, headers = o.token:request(args)
  if not toks then
    return nil, err
  end

  local expires_in

  if type(toks) == "table" then
    if toks.expires_in then
      expires_in = tonumber(toks.expires_in)
    end

    if not expires_in then
      if toks.exp then
        local exp = tonumber(toks.exp)
        if exp then
          expires_in = exp - time()
        end
      end
    end
  end

  if expires_in and expires_in < 0 then
    expires_in = nil
  end

  return { toks, headers }, nil, expires_in
end


function tokens.load(o, args, ttl)
  local iss = o.configuration.issuer
  local key

  if args.grant_type == "password" then
    key = cache_key(concat{ iss, "#username=", args.username, "&password=", hash.S256(args.password) })

  elseif args.grant_type == "client_credentials" then
    key = cache_key(concat{ iss, "#client_id=", args.client_id, "&client_secret=", hash.S256(args.client_secret) })

  else
    -- we don't cache authorization code requests
    return o.token:request(args)
  end

  local res, err = cache_get(key, ttl, tokens.init, o, args)

  if not res then
    return nil, err
  end

  return res[1], nil, res[2]
end


local userinfo = {}


function userinfo.init(o, access_token)
  log(NOTICE, "[openid-connect] loading user info using access token from identity provider")
  return o:userinfo(access_token, { userinfo_format = "base64" })
end


function userinfo.load(o, access_token, ttl)
  local iss = o.configuration.issuer
  local key = cache_key(iss .. "#userinfo=" .. access_token)

  return cache_get(key, ttl, userinfo.init, o, access_token)
end


return {
  init_worker   = init_worker,
  issuers       = issuers,
  consumers     = consumers,
  oauth2        = oauth2,
  introspection = introspection,
  tokens        = tokens,
  userinfo      = userinfo,
  version       = "0.0.8",
}
