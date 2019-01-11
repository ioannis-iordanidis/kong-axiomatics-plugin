local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.kong-axiomatics-plugin.access"

local AxiomaticsHandler = BasePlugin:extend()

AxiomaticsHandler.PRIORITY = 2000

function AxiomaticsHandler:new()
  AxiomaticsHandler.super.new(self, "axiomatics-plugin")
end

function AxiomaticsHandler:access(conf)
  AxiomaticsHandler.super.access(self)
  access.execute(conf)
end

return AxiomaticsHandler
