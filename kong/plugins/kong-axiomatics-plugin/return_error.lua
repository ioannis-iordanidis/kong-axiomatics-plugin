local _M = {}

-- Utility function to avoid code duplication
function _M.exit(message, status)
  ngx.say(message)
  ngx.status = status
  return ngx.exit(ngx.HTTP_OK)
end

return _M
