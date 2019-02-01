local _M = {}

-- Utility function to avoid code duplication
function _M.exit(message, status)
  ngx.status = status
  ngx.say(message)
  return ngx.exit(ngx.HTTP_OK)
end

return _M
