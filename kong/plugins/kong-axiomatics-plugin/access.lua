local jwt_decoder = require "kong.plugins.jwt.jwt_parser"

local _M = {}

-- Parse the JWT --
local function extract(conf)
  local jwt
  local err
  local header = ngx.req.get_headers()[conf.token_header_name]

  if header == nil then
    err = "No token found using header: " .. conf.token_header_name
    ngx.log(ngx.ERR, err)
    return nil, err
  end

  if header:find(" ") then
    local divider = header:find(' ')
    if string.lower(header:sub(0, divider-1)) == string.lower("Bearer") then
      jwt = header:sub(divider+1)
      if jwt == nil then
        err = "No Bearer token value found from header: " .. conf.token_header_name
        ngx.log(ngx.ERR, err)
        return nil, err
      end
    end
  end

  if jwt == nil then
    jwt = header
  end

  ngx.log(ngx.ERR, "JWT token located using header: " .. conf.token_header_name .. ", token length: " .. string.len(jwt))
  return jwt, err
end


function _M.execute(conf)

-- Decode JWT --
local token, error = extract(conf)
local jwt, err = jwt_decoder:new(token)
if not err then
  ngx.log(ngx.ERR, "Decoded JWT!!")
end

local claims = jwt.claims
for claim_key,claim_value in pairs(claims) do
  for _,claim_pattern in pairs(conf.claims_to_include) do
    if string.match(claim_key, "^"..claim_pattern.."$") then
      ngx.log(ngx.ERR, "claim key:" .. claim_key)
    end
  end
end

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
