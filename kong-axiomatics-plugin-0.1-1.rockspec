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
    ["kong.plugins.axiomatics.handler"] = "kong/plugins/kong-axiomatics-plugin/handler.lua",
    ["kong.plugins.axiomatics.schema"] = "kong/plugins/kong-axiomatics-plugin/schema.lua"
  }
}
