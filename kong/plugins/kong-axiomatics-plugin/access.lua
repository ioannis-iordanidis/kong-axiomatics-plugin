local retrieve_token = require "kong.plugins.kong-axiomatics-plugin.access_retrieve_token"
local decode_token = require "kong.plugins.kong-axiomatics-plugin.access_decode_token"
local compose_post_payload = require "kong.plugins.kong-axiomatics-plugin.access_compose_post_payload"
local sent_post_request = require "kong.plugins.kong-axiomatics-plugin.access_sent_post_request"
local make_decision = require "kong.plugins.kong-axiomatics-plugin.access_decision"

local _M = {}

function _M.execute(conf)
  local token = retrieve_token.retrieve_token(conf)
  local decoded_token, err = decode_token.decode_token(token)
  local payload = compose_post_payload.compose_post_payload(decoded_token, conf)
  local pdp_response_body = sent_post_request.sent_post_request(payload, conf)
  make_decision.decision(pdp_response_body)
end

return _M
