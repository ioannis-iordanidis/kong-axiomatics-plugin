local return_error = require "kong.plugins.kong-axiomatics-plugin.lib.return_error"

local _M = {}

-- Decide whether or not to proxy the request upstream based on the PDP response
function _M.decision(response)
  local pdp_decision = response.Response[1].Decision
  ngx.log(ngx.ERR, "Decision: ", pdp_decision)

  --if pdp_decision ~= "Permit" and pdp_decision ~= "NotApplicable" then -- TODO parametrise that
    if pdp_decision ~= "Permit" then
    local message = "Request was not authorised by PDP"
    ngx.log(ngx.ERR, message)
    return_error.exit(message, ngx.HTTP_FORBIDDEN)
  else -- authorised
    ngx.log(ngx.ERR, "Request was authorised by PDP, proxying upstream")
  end
end

return _M
