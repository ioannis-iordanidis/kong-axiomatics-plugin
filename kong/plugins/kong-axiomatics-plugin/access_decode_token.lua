local jwt_decoder = require "kong.plugins.jwt.jwt_parser"

local _M = {}

-- Decode JWT from Base64 to Kong JWT parser
  function _M.decode_token(token)
    local decoded_token, err = jwt_decoder:new(token)
    if err then
      ngx.log(ngx.ERR, "Not able to decode JWT token with error ", err)
    else
      ngx.log(ngx.ERR, "JWT token decoded")
    end
    return decoded_token, err
  end

return _M
