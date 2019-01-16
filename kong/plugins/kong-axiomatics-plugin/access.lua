local jwt_decoder = require "kong.plugins.jwt.jwt_parser"
local re_gmatch = ngx.re.gmatch

local _M = {}

-- Retrieve JWT from the parametrised request header name --
local function retrieve_token(conf)
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

-- Decode JWT from Base64 to Kong JWT parser
local function decode_token(token)
  local decoded_token, err = jwt_decoder:new(token)
  if err then
    ngx.log(ngx.ERR, "Not able to decode JWT token with error ", err)
  else
    ngx.log(ngx.ERR, "JWT token decoded")
  end
  return decoded_token, err
end

-- Parse the selected claims out of the JWT to a POST body --
local function compose_post_payload(decoded_token, conf)
  local claims = decoded_token.claims
  for claim_key,claim_value in pairs(claims) do
    for _,claim_pattern in pairs(conf.claims_to_include) do
      if string.match(claim_key, "^"..claim_pattern.."$") then
        if (type(claim_value) == "table") then
          ngx.log(ngx.ERR, "claim key: " .. claim_key .. ", claim_value: " .. table.concat(claim_value))
        else
          ngx.log(ngx.ERR, "claim key: " .. claim_key .. ", claim_value: " .. claim_value)
        end
      end
    end
  end
end

function _M.execute(conf)
  local token, error = retrieve_token(conf)
  local decoded_token, err = decode_token(token)
  compose_post_payload(decoded_token, conf)

-- Send an empty POST request to a mock --
  local sock = ngx.socket.tcp()
  sock:settimeout(1000)

  local ok, err = sock:connect("optum.proxy.beeceptor.com", 443)
  if not ok then
    ngx.log(ngx.ERR, "failed to connect ", err)
  end

  local ok, err = sock:sslhandshake()
  if not ok then
    ngx.log(ngx.ERR,  "failed to do SSL handshake with ", err)
  else
    ngx.log(ngx.ERR, "no ssl error: ", tostring(ok))
  end

  local ok, err = sock:send("GET /middleman HTTP/1.1\r\nHost: optum.proxy.beeceptor.com\r\nConnection: close\r\n\r\n")
  if not ok then
    ngx.log(ngx.ERR, "failed to send ", err)
  else
    ngx.log(ngx.ERR, "no send error: ", ok)
  end

  local line, err = sock:receive()
  if not line then
    ngx.log(ngx.ERR,  "failed to read response: ", err)
  else
    ngx.log(ngx.ERR, "no error, line: ", line)
  end

-- Insert a Hello World header --
  if conf.say_hello then
    ngx.log(ngx.ERR, "============ Hello World! ============")
    ngx.header["Hello-World-6"] = "Hello World!"
  else
    ngx.log(ngx.ERR, "============ Bye World! ============")
    ngx.header["Hello-World"] = "Bye World!"
  end
end

return _M
