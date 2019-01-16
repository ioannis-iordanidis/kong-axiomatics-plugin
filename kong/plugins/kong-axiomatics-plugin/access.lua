local jwt_decoder = require "kong.plugins.jwt.jwt_parser"
local JSON = require "kong.plugins.kong-axiomatics-plugin.json"

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
  local payload = {}
  for claim_key,claim_value in pairs(claims) do
    for _,claim_pattern in pairs(conf.claims_to_include) do
      if string.match(claim_key, "^"..claim_pattern.."$") then
        payload[claim_key] = claim_value
      end
    end
  end
  ngx.log(ngx.ERR, "Selected claim and values parsed out of the JWT:\n" .. JSON:encode_pretty(payload) .. "\n")
  return JSON:encode_pretty(payload)
end

-- Main function called from the Handler --
function _M.execute(conf)
  local token, error = retrieve_token(conf)
  local decoded_token, err = decode_token(token)
  local payload = compose_post_payload(decoded_token, conf)

-- POST the payload to a listening mock --
  local sock = ngx.socket.tcp()
  sock:settimeout(1000)

  local ok, err = sock:connect("optum.proxy.beeceptor.com", 443)
  if not ok then
    ngx.log(ngx.ERR, "Failed to connect ", err)
  end

  local ok, err = sock:sslhandshake()
  if not ok then
    ngx.log(ngx.ERR,  "Failed to do SSL handshake with ", err)
  else
    ngx.log(ngx.ERR, "No ssl error: ", tostring(ok))
  end

  local post_request = string.format(
    "POST %s HTTP/1.1\r\nHost: %s\r\nConnection: Keep-Alive\r\nContent-Type: application/json\r\nContent-Length: %s\r\n\r\n%s",
    "/middleman", "optum.proxy.beeceptor.com", #payload, payload)
  ngx.log(ngx.ERR,  "--------> Post request:\n", post_request .. "\n")
  local ok, err = sock:send(post_request)
  if not ok then
    ngx.log(ngx.ERR, "Failed to send ", err)
  else
    ngx.log(ngx.ERR, "No send error: ", ok)
  end

  local line, err = sock:receive()
  if not line then
    ngx.log(ngx.ERR,  "Failed to read response: ", err)
  else
    ngx.log(ngx.ERR, "No error, line: ", line)
  end
end

return _M
