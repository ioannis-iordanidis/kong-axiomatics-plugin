local BasePlugin = require "kong.plugins.base_plugin"
local inject_header = require "kong.plugins.kong-axiomatics-plugin.inject_header"
local request = require "kong.plugins.kong-axiomatics-plugin.request"

local AxiomaticsHandler = BasePlugin:extend()

AxiomaticsHandler.PRIORITY = 2000

function AxiomaticsHandler:new()
  AxiomaticsHandler.super.new(self, "axiomatics-plugin")
end

function AxiomaticsHandler:access(conf)
  AxiomaticsHandler.super.access(self)
  inject_header.execute(conf)
  request.execute(conf)
end

return AxiomaticsHandler
