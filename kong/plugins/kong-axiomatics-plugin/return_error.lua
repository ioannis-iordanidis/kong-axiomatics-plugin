local _M = {}

-- Utility function to avoid code duplication
function _M.exit(message, http_status)
  ngx.status = http_status
  ngx.say(message)
  return ngx.exit(ngx.HTTP_OK)
end

return _M
