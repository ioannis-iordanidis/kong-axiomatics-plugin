local return_error = require "kong.plugins.kong-axiomatics-plugin.lib.return_error"


local _M = {}

-- Retrieve JWT from the parametrised request header name --
  function _M.retrieve_token(conf)
    local jwt
    local header = ngx.req.get_headers()[conf.token_header_name]

    if header == nil then
      local message = conf.token_header_name .. " header not present"
      ngx.log(ngx.ERR, message)
      return_error.exit(message, ngx.HTTP_BAD_REQUEST)
    end

    local divider = header:find(' ')
    if not divider then
      local message = "Expecting a space in the value of the " .. conf.token_header_name .. " header"
      ngx.log(ngx.ERR, message)
      return_error.exit(message, ngx.HTTP_BAD_REQUEST)
    end

    if string.lower(header:sub(0, divider-1)) == string.lower("Bearer") then
      jwt = header:sub(divider+1)
    else
      local message = conf.token_header_name .. " header not in the exected <Authorization:Bearer jwt> format"
      ngx.log(ngx.ERR, message)
      return_error.exit(message, ngx.HTTP_BAD_REQUEST)
    end

    ngx.log(ngx.DEBUG, "JWT token located using header: " .. conf.token_header_name .. ", token length: " .. string.len(jwt))
    return jwt
  end

return _M
