local re_gmatch = ngx.re.gmatch

local _M = {}

-- Retrieve JWT from the parametrised request header name --
  function _M.retrieve_token(conf)
    local authorization_header = kong.request.get_header(conf.token_header_name)
    if authorization_header then
      local iterator, iter_err = re_gmatch(authorization_header, "\\s*[Bb]earer\\s+(.+)")
      if not iterator then
        ngx.log(ngx.ERR, "No token found using header: " .. conf.token_header_name)
        return nil, iter_err
      end

      local m, err = iterator()
      if err then
        ngx.log(ngx.ERR, "No Bearer token value found from header: " .. conf.token_header_name)
        return nil, err
      end

      if m and #m > 0 then
        ngx.log(ngx.ERR, "JWT token located using header: " .. conf.token_header_name .. ", token length: " .. string.len(m[1]))
        return m[1]
      end
    end
  end

return _M
