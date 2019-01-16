return {
  fields = {
    say_hello = {type = "boolean", default = true},
    url = {required = true, type = "string"},
    token_header_name = {type = "string", required = true, default = "Authorization"},
    claims_to_include = {type = "array", default = {".*"}}
  }
}
