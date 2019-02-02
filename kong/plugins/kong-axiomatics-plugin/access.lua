local retrieve_token = require "kong.plugins.kong-axiomatics-plugin.access_retrieve_token"
local decode_token = require "kong.plugins.kong-axiomatics-plugin.access_decode_token"
local compose_post_payload = require "kong.plugins.kong-axiomatics-plugin.access_compose_post_payload"
local sent_post_request = require "kong.plugins.kong-axiomatics-plugin.access_sent_post_request"
local make_decision = require "kong.plugins.kong-axiomatics-plugin.access_decision"

local _M = {}

function _M.execute(conf)
  local base64_token = retrieve_token.retrieve_token(ngx.req.get_headers()[conf.token_header_name], conf)
  local token = decode_token.decode_token(base64_token)
  local payload = compose_post_payload.compose_post_payload(token, conf)
  local pdp_xacml_response = sent_post_request.sent_post_request(payload, conf)
  make_decision.decision(pdp_xacml_response)
end

return _M
