-- This software is copyright Kong Inc. and its licensors.
-- Use of the software is subject to the agreement between your organization
-- and Kong Inc. If there is no such agreement, use is governed by and
-- subject to the terms of the Kong Master Software License Agreement found
-- at https://konghq.com/enterprisesoftwarelicense/.
-- [ END OF LICENSE 0867164ffc95e54f04670b5169c09574bdbd9bba ]

local utils = require "kong.tools.utils"
local redis = require "kong.enterprise_edition.redis"

local ngx_log   = ngx.log
local ERR       = ngx.ERR
local ngx_time  = ngx.time
local ceil      = math.ceil
local floor     = math.floor
local tonumber  = tonumber
local type      = type
local fmt       = string.format
local tb_insert = table.insert
local tb_concat = table.concat


local function log(lvl, ...)
  ngx_log(lvl, "[rate-limiting] ", ...)
end


local _M = {}
local mt = { __index = _M }


local function window_floor(size, time)
  return floor(time / size) * size
end


function _M.new(_, opts)
  local conf = utils.cycle_aware_deep_copy(opts)

  -- initialize redis configuration - e.g., parse
  -- Sentinel addresses
  redis.init_conf(conf)

  return setmetatable({
    config = conf,
  }, mt)
end


function _M:push_diffs(diffs)
  if type(diffs) ~= "table" then
    error("diffs must be a table", 2)
  end

  if #diffs == 0 then
    return true
  end

  local red, err = redis.connection(self.config)
  if not red then
    return nil, fmt("failed to connect to redis: %s", err)
  end

  red:init_pipeline()

  for i = 1, #diffs do
    local key     = diffs[i].key
    local windows = diffs[i].windows

    for j = 1, #windows do
      local rkey = windows[j].window .. ":" .. windows[j].size .. ":" ..
                   windows[j].namespace

      red:hincrby(rkey, key, windows[j].diff)
      red:expire(rkey, 2 * windows[j].size)
    end
  end

  local results, err = red:commit_pipeline()
  if not results then
    return nil, fmt("failed to push diff pipeline: %s", err)
  end

  -- redis cluster library handles keepalive itself
  if not redis.is_redis_cluster(self.config) then
    red:set_keepalive()
  end

  local err_tab = {}
  for i, res in ipairs(results) do
    -- the res would be `{false, err}` if the query fails
    if type(res) == "table" and #res == 2 and res[1] == false then
      tb_insert(err_tab, fmt("query #%s in the push diffs pipeline failed: %s", i, res[2]))
    end
  end

  if next(err_tab) then
    return nil, tb_concat(err_tab, ", ")
  end

  return true
end


function _M:get_counters(namespace, window_sizes, time)
  local red, err = redis.connection(self.config)
  if not red then
    return nil, fmt("failed to connect to redis: %s", err)
  end

  time = time or ngx_time()

  red:init_pipeline()

  for i = 1, #window_sizes do
    local floor = window_floor(window_sizes[i], time)
    red:hgetall(floor .. ":" .. window_sizes[i] .. ":" .. namespace)
    red:hgetall(floor -  window_sizes[i] .. ":" .. window_sizes[i] .. ":" ..
                namespace)
  end

  local res, err = red:commit_pipeline()
  if not res then
    return nil, fmt("failed to retrieve keys: %s", err)
  end

  -- redis cluster library handles keepalive itself
  if not redis.is_redis_cluster(self.config) then
    red:set_keepalive()
  end

  local err_tab = {}
  for i, r in ipairs(res) do
    -- the r would be `{false, err}` if the query fails
    if type(r) == "table" and #r == 2 and r[1] == false then
      tb_insert(err_tab, fmt("query #%s in the get counters pipeline failed: %s", i, r[2]))
    end
  end

  if next(err_tab) then
    local err_msg = tb_concat(err_tab, ", ")
    log(ERR, err_msg)
  end

  local num_hashes = #res
  local res_idx = 0
  local hash_idx
  local hash

  local function iter()
    if not hash then
      res_idx = res_idx + 1

      if res_idx > num_hashes then
        return
      end

      hash = res[res_idx]
      hash_idx = 0
    end

    hash_idx = hash_idx + 1

    local key = hash[hash_idx]
    local value = hash[hash_idx + 1]
    if not key then
      hash = nil
      return iter()
    end

    -- jump past the value for this key
    hash_idx = hash_idx + 1

    -- return what looks like a psql/c* row. key and count are easy :)
    -- window size and start are a little trickier. since we are iterating over
    -- 2 * #window_sizes elements, we figure these based on our current iterator
    -- idx. the window start is either the the value of window_floor() based the
    -- current window size, or `window_size` seconds less than the current floor
    return {
      window_size = window_sizes[ceil(res_idx / 2)],
      window_start = window_floor(window_sizes[ceil(res_idx / 2)], time) -
                     (((res_idx + 1) % 2) * window_sizes[ceil(res_idx / 2)]),
      key = key,
      count = tonumber(value),
    }
  end

  return iter
end


function _M:get_window(key, namespace, window_start, window_size)
  local red, err = redis.connection(self.config)
  if not red then
    return nil, fmt("failed to connect to redis: %s", err)
  end

  local rkey = window_start .. ":" .. window_size .. ":" .. namespace

  local res, err = red:hget(rkey, key)
  if not res then
    return nil, fmt("failed to retrieve %s : %s", key, err)
  end

  -- redis cluster library handles keepalive itself
  if not redis.is_redis_cluster(self.config) then
    red:set_keepalive()
  end

  return tonumber(res)
end


function _M:purge()
  -- noop: redis strategy uses `:expire` to purge old entries
  return true
end

return _M
