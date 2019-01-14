local _M = {}

function _M.execute(conf)
  ngx.header["Hello-World 2"] = "Hello World 2!"
end

return _M
