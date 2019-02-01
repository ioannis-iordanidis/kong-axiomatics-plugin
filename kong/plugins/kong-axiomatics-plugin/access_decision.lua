local _M = {}

-- Decide whether or not to proxy the request upstream based on the PDP response
function _M.decision(response)
  local pdp_decision = response.Response[1].Decision
  ngx.log(ngx.ERR, "Decision: ", pdp_decision)

  if pdp_decision ~= "Permit" and pdp_decision ~= "NotApplicable" then -- parametrise that
    ngx.log(ngx.ERR, "Request was not authorised by PDP, returning 403.")
    ngx.status = ngx.HTTP_FORBIDDEN
    ngx.say("Not Authorised")
    return ngx.exit(ngx.HTTP_OK)
  else -- authorised
    ngx.log(ngx.ERR, "Request was authorised by PDP, proxyinng upstream.")
  end
end

return _M
