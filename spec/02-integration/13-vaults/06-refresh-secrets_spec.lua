-- This software is copyright Kong Inc. and its licensors.
-- Use of the software is subject to the agreement between your organization
-- and Kong Inc. If there is no such agreement, use is governed by and
-- subject to the terms of the Kong Master Software License Agreement found
-- at https://konghq.com/enterprisesoftwarelicense/.
-- [ END OF LICENSE 0867164ffc95e54f04670b5169c09574bdbd9bba ]


local helpers = require "spec.helpers" -- initializes 'kong' global for vaults


for _, strategy in helpers.each_strategy() do
  describe("Config change awareness in vaults #" .. strategy, function()
    local admin_client, proxy_client, plugin

    lazy_setup(function()
      local bp = helpers.get_db_utils(strategy, { "vaults" }, { "dummy" }, { "env" })

      local route = bp.routes:insert {
        paths = { "/" },
      }

      bp.vaults:insert {
        name = "env",
        prefix = "test-env"
      }

      plugin = bp.plugins:insert {
        name   = "dummy",
        route  = { id = route.id },
        config = {
          resp_header_value = '{vault://test-env/gila}',
          resp_headers = {
            ["X-Test-This"] = "no-reference-yet",
          },
        },
      }

      helpers.setenv("GILA", "MONSTER")
      helpers.setenv("MOTOR", "SPIRIT")
      assert(helpers.start_kong {
        database = strategy,
        prefix = helpers.test_conf.prefix,
        nginx_conf = "spec/fixtures/custom_nginx.template",
        plugins = "dummy",
        vaults = "env",
      })
    end)

    before_each(function()
      admin_client = assert(helpers.admin_client())
      proxy_client = assert(helpers.proxy_client())
    end)

    after_each(function()
      if admin_client then
        admin_client:close()
      end
      if proxy_client then
        proxy_client:close()
      end
    end)

    lazy_teardown(function()
      helpers.stop_kong()
    end)

    it("should be able to detect new references when plugin config changes", function()
      local res = proxy_client:get("/")
      assert.response(res).has.status(200)
      local ref = res.headers["Dummy-Plugin"]
      local no_ref = res.headers["X-Test-This"]
      assert.is_same("MONSTER", ref)
      assert.is_same("no-reference-yet", no_ref)
      local res = admin_client:patch("/plugins/" .. plugin.id, {
        body = {
          config = {
            resp_headers = {
              ["X-Test-This"] = '{vault://test-env/motor}',
            },
          }
        },
        headers = { ["Content-Type"] = "application/json" },
      })
      assert.res_status(200, res)

      assert
          .with_timeout(10)
          .eventually(function()
            local res = proxy_client:send {
              method = "GET",
              path = "/",
            }
            return res and res.status == 200 and res.headers["Dummy-Plugin"] == "MONSTER" and res.headers["X-Test-This"] == "SPIRIT"
          end).is_truthy("Could not find header in request")
    end)
  end)
end