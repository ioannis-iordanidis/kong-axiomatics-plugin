local jwt_decoder = require "kong.plugins.jwt.jwt_parser"
local return_error = require "kong.plugins.kong-axiomatics-plugin.return_error"

local _M = {}

-- Decode JWT from Base64 to Kong JWT parser
function _M.decode_token(token)
  local decoded_token, err = jwt_decoder:new(token)
  if err then
    local message = "Decoded Base64 string is not a JWT token"
    ngx.log(ngx.ERR, message)
    return_error.exit(message, ngx.HTTP_BAD_REQUEST)
  end
  ngx.log(ngx.ERR, "JWT token decoded")
  return decoded_token
end

return _M
