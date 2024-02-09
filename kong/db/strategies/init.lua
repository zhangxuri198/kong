local load_module_if_exists = require "kong.tools.module".load_module_if_exists


local fmt = string.format


local _M = {}


_M.STRATEGIES   = {
  ["postgres"]  = true,
  ["off"] = true,
}


function _M.new(kong_config, database, schemas, errors)
  local database = database or kong_config.database

  if not _M.STRATEGIES[database] then
    error("unknown strategy: " .. database, 2)
  end

  -- strategy-specific connector with :connect() :setkeepalive() :query() ...
  local Connector = require(fmt("kong.db.strategies.%s.connector", database))

  -- strategy-specific automated CRUD query builder with :insert() :select()
  local Strategy = require(fmt("kong.db.strategies.%s", database))

  local connector, err = Connector.new(kong_config)
  if not connector then
    return nil, nil, err
  end

  do
    local base_connector = require "kong.db.strategies.connector"
    local mt = getmetatable(connector)
    setmetatable(mt, {
      __index = function(t, k)
        -- explicit parent
        if k == "super" then
          return base_connector
        end

        return base_connector[k]
      end
    })
  end

  local strategies = {}

  for _, schema in pairs(schemas) do
    local strategy, err = Strategy.new(connector, schema, errors)
    -- TODO: also load keyauth and basic auth credentials
    if schema.name == "consumers" and
       kong_config.lazy_loaded_consumers == "on" and
       kong_config.role == "data_plane" and
       kong_config.database == "off" then

      strategy = "lazy"
      local lazy_Connector = require(fmt("kong.db.strategies.%s.connector", strategy))
      local lazy_connector, err = lazy_Connector.new(kong_config)
      -- Also implement a simple connector for the lazy strategy
      -- that only implemenets query.
      local lazy_Strategy = require(fmt("kong.db.strategies.%s", strategy))
      strategy, err = lazy_Strategy.new(lazy_connector, schema, errors)
    end
    print("schema.name = " .. require("inspect")(schema.name))
    if not strategy then
      return nil, nil, err
    end

    local custom_strat = fmt("kong.db.strategies.%s.%s", database, schema.name)
    local exists, mod = load_module_if_exists(custom_strat)
    if exists and mod then
      local parent_mt = getmetatable(strategy)
      local mt = {
        __index = function(t, k)
          -- explicit parent
          if k == "super" then
            return parent_mt
          end

          -- override
          local f = mod[k]
          if f then
            return f
          end

          -- parent fallback
          return parent_mt[k]
        end
      }
      setmetatable(strategy, mt)
    end

    strategies[schema.name] = strategy
  end

  return connector, strategies
end


return _M
