local jwt_decoder = require "kong.plugins.jwt.jwt_parser"
local JSON = require "kong.plugins.kong-axiomatics-plugin.json"
local socket_url = require "socket.url"

local re_gmatch = ngx.re.gmatch

local HTTP = "http"
local HTTPS = "https"

local _M = {}

local function parse_url(url)
  local parsed_url = socket_url.parse(url)
  if not parsed_url.port then
    if parsed_url.scheme == HTTP then
      parsed_url.port = 80
     elseif parsed_url.scheme == HTTPS then
      parsed_url.port = 443
     end
  end
  if not parsed_url.path then
    parsed_url.path = "/"
  end
  return parsed_url
end

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

-- Compose XACML POST body --
local function compose_post_payload(decoded_token, conf)

  -- AccessSubject XACML values
  local access_subject_attribute_list = {}
  local access_subject = {}
  local claims = decoded_token.claims
  for claim_key,claim_value in pairs(claims) do
    for i,claim_pattern in pairs(conf.claims_to_include) do
      if string.match(claim_key, "^"..claim_pattern.."$") then
        local key_value = {}
        key_value["AttributeId"] = claim_key
        key_value["Value"] = claim_value
        access_subject_attribute_list[i] = key_value
      end
    end
  end
  access_subject["Attribute"] = access_subject_attribute_list

  -- Action XACML values
  local action_attribute = {}
  local action = {}
  action_attribute["AttributeId"] = "action-id"
  action_attribute["Value"] = ngx.var.scheme .. "//" .. ngx.var.host .. ngx.var.request_uri
  action_attribute["DataType"] = "anyURI"
  action["Attribute"] = action_attribute

  -- Resource XACML values TODO

  -- Payload
  request = {}
  payload = {}
  request["AccessSubject"] = access_subject
  request["Action"] = action
  payload["Request"] = request
  return JSON:encode_pretty(payload)
end

function _M.execute(conf)
  local token, error = retrieve_token(conf)
  local decoded_token, err = decode_token(token)
  local payload = compose_post_payload(decoded_token, conf)

  -- POST the payload to the PDP endpoint --
  local parsed_url = parse_url(conf.pdp_url)
  local host = parsed_url.host
  local port = tonumber(parsed_url.port)

  local sock = ngx.socket.tcp()
  sock:settimeout(1000)

  local ok, err = sock:connect(host, port)
  if not ok then
    ngx.log(ngx.ERR, "Failed to connect to " .. host .. ":" .. tostring(port) .. ": ", err)
  end

  if parsed_url.scheme == HTTPS then
    local ok, err = sock:sslhandshake()
    if not ok then
      ngx.log(ngx.ERR, "Failed to do SSL handshake with " .. host .. ":" .. tostring(port) .. ": ", err)
    else
      ngx.log(ngx.ERR, "No ssl error: ", tostring(ok))
    end
  end

  local post_request = string.format(
    "POST %s HTTP/1.1\r\nHost: %s\r\nConnection: Keep-Alive\r\nContent-Type: application/json\r\nContent-Length: %s\r\n\r\n%s",
    parsed_url.path, parsed_url.host, #payload, payload)
  ngx.log(ngx.ERR, "Post request:\n", post_request .. "\n")
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
