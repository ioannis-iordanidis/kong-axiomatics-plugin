local socket_url = require "socket.url"
local JSON = require "kong.plugins.kong-axiomatics-plugin.lib.json"
local return_error = require "kong.plugins.kong-axiomatics-plugin.return_error"

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

-- POST the payload to the PDP endpoint --
function _M.sent_post_request(payload, conf)
  local parsed_url = parse_url(conf.pdp_url)
  local host = parsed_url.host
  local port = tonumber(parsed_url.port)

  local sock = ngx.socket.tcp()
  sock:settimeout(1000) -- TODO parametrise that

  local ok, err = sock:connect(host, port)
  if not ok then
    local message = "Failed to connect to " .. host .. ":" .. tostring(port) .. ": " .. err
    ngx.log(ngx.ERR, message)
    return_error.exit(message, ngx.HTTP_SERVICE_UNAVAILABLE)
  end

  if parsed_url.scheme == HTTPS then
    local ok, err = sock:sslhandshake()
    if not ok then
      local message = "Failed to do SSL handshake with " .. host .. ":" .. tostring(port) .. ": " .. err
      ngx.log(ngx.ERR, message)
      return_error.exit(message, ngx.HTTP_SERVICE_UNAVAILABLE)
    end
  end

  local authorization_header = ""
  if conf.basic_http_auth then
    local base64_credentials = ngx.encode_base64(conf.pdp_username .. ":" .. conf.pdp_password)
    authorization_header = "Authorization: Basic " .. base64_credentials .. "\r\n"
  end

  local post_request = string.format(
    "POST %s HTTP/1.1\r\n\z
    Host: %s\r\n\z
    %s\z
    Connection: Keep-Alive\r\n\z
    Content-Type: application/json\r\n\z
    Content-Length: %s\r\n\z
    \r\n\z
    %s",
    parsed_url.path, parsed_url.host, authorization_header, #payload, payload)

  ngx.log(ngx.ERR, "Post request to PDP:\n", post_request, "\n")
  local ok, err = sock:send(post_request)
  if not ok then
    local message = "Failed to send request to PDP" .. err
    ngx.log(ngx.ERR, message)
    return_error.exit(message, ngx.HTTP_SERVICE_UNAVAILABLE)
  else
    ngx.log(ngx.ERR, "No send error: ", ok)
  end

  -- Parse the response --
  local line, err = sock:receive("*l") -- each call returns a single line
  if err then
    local message = "Failed to read response from PDP: " .. err
    ngx.log(ngx.ERR, message)
    return_error.exit(message, ngx.HTTP_SERVICE_UNAVAILABLE)
  end

  local status_code = tonumber(string.match(line, "%s(%d%d%d)%s"))
  if status_code ~= 200 then
      local message = "Error response from PDP: " .. line
      ngx.log(ngx.ERR, message)
      return_error.exit(message, ngx.HTTP_BAD_GATEWAY)
  else
      ngx.log(ngx.ERR, "PDP response: ", line)
  end

  local headers = {} -- response headers
  repeat
    line, err = sock:receive("*l")
    if err then
      local message = "Failed to read header from PDP response: " .. err
      ngx.log(ngx.ERR, message)
      return_error.exit(message, ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    local pair = ngx.re.match(line, "(.*):\\s*(.*)", "jo")
    if pair then
      headers[string.lower(pair[1])] = pair[2]
    end
  until ngx.re.find(line, "^\\s*$") -- first empty line

  local body, err = sock:receive(tonumber(headers['content-length']))
  if err then
    local message = "Failed to read body from PDP response: " .. err
    ngx.log(ngx.ERR, message)
    return_error.exit(message, ngx.HTTP_INTERNAL_SERVER_ERROR)
  end
  body = JSON:decode(body)
  ngx.log(ngx.ERR, "Response body from PDP:\n", JSON:encode_pretty(body), "\n")

  return body
end

return _M
