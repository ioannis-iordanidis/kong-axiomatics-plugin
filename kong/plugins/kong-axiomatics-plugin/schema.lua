return {
  no_consumer = true, -- this plugin will only be applied to Services or Routes
  fields = {
    pdp_url = {type = "string", required = true},
    basic_http_auth = {type = "boolean", required = false, default = false},
    pdp_username = {type = "string", required = false},
    pdp_password = {type = "string", required = false},
    token_header_name = {type = "string", required = true, default = "Authorization"},
    claims_to_include = {type = "array", default = {".*"}}
  }
}
