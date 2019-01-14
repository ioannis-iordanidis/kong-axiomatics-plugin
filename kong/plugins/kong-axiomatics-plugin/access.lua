local _M = {}

function _M.execute(conf)

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
