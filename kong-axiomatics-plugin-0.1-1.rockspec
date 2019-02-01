package = "kong-axiomatics-plugin"
version = "0.1-1"
supported_platforms = {"linux", "macosx"}
source = {
  url = "git@github.com:ioannis-iordanidis/kong-axiomatics-plugin.git",
  tag = "v0.1-1"
}
description = {
  summary = "Kong Axiomatics Integration",
  license = "Apache 2.0",
  homepage = "https://github.com/ioannis-iordanidis/kong-axiomatics-plugin",
  detailed = [[
      Kong Axiomatics Integration.
  ]],
}
dependencies = {
  "lua ~> 5.1"
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins.axiomatics.access"] = "kong/plugins/kong-axiomatics-plugin/access.lua",
    ["kong.plugins.axiomatics.lib.json"] = "kong/plugins/kong-axiomatics-plugin/lib/json.lua",
    ["kong.plugins.axiomatics.return_error"] = "kong/plugins/kong-axiomatics-plugin/return_error.lua",
    ["kong.plugins.axiomatics.handler"] = "kong/plugins/kong-axiomatics-plugin/handler.lua",
    ["kong.plugins.axiomatics.schema"] = "kong/plugins/kong-axiomatics-plugin/schema.lua",
    ["kong.plugins.axiomatics.access_retrieve_token"] = "kong/plugins/kong-axiomatics-plugin/access_retrieve_token.lua",
    ["kong.plugins.axiomatics.access_decode_token"] = "kong/plugins/kong-axiomatics-plugin/access_decode_token.lua",
    ["kong.plugins.axiomatics.access_compose_post_payload"] = "kong/plugins/kong-axiomatics-plugin/access_compose_post_payload.lua",
    ["kong.plugins.axiomatics.access_sent_post_request"] = "kong/plugins/kong-axiomatics-plugin/access_sent_post_request.lua",
    ["kong.plugins.axiomatics.access_decision"] = "kong/plugins/kong-axiomatics-plugin/access_decision.lua"
  }
}
