local socket_url = require "socket.url"

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

    local line, err = sock:receive("*l")
    if err then
      ngx.log(ngx.ERR,  "Failed to read response: ", err)
    else
      ngx.log(ngx.ERR, "No error, respose: ", line)
    end

    return line -- TODO return the whole response
  end

return _M
