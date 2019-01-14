local _M = {}

function _M.execute(conf)

  local sock = ngx.socket.tcp()
  sock:settimeout(10000)
  sock:connect("optum.free.beeceptor.com/middleman", 443)
  sock:sslhandshake(true, host, false)
  sock:send("foo bar")

  if conf.say_hello then
    ngx.log(ngx.ERR, "============ Hello World! ============")
    ngx.header["Hello-World-4"] = "Hello World!"
  else
    ngx.log(ngx.ERR, "============ Bye World! ============")
    ngx.header["Hello-World"] = "Bye World!"
  end
end

return _M
