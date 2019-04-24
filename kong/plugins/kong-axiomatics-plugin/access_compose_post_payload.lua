local JSON = require "kong.plugins.kong-axiomatics-plugin.lib.json"
local return_error = require "kong.plugins.kong-axiomatics-plugin.return_error"

local _M = {}

-- Compose XACML POST body --
function _M.compose_post_payload(decoded_token, conf)
  -- AccessSubject XACML values from JWT
  local access_subject_attribute_list = {}
  local access_subject = {}
  local claims = decoded_token.claims
  for claim_key,claim_value in pairs(claims) do
    for i,claim_pattern in pairs(conf.claims_to_include) do
      if claim_key == claim_pattern then
        local key_value = {}
        key_value["AttributeId"] = claim_key
        key_value["Value"] = claim_value
        access_subject_attribute_list[i] = key_value
      end
    end
  end
  -- AccessSubject XACML values from URI path
  if conf.url_parameter_matching then
    local key_value = {}
    key_value["AttributeId"] = conf.url_parameter_key
    key_value["Value"] = string.match(ngx.var.request_uri, "([^/]+)$")
    table.insert(access_subject_attribute_list, key_value)
  end

  access_subject["Attribute"] = access_subject_attribute_list

  -- Action XACML values
  local action_attribute = {}
  local action = {}
  action_attribute["AttributeId"] = "action-id"
  action_attribute["Value"] = ngx.var.scheme .. "://" .. ngx.var.host .. ngx.var.request_uri
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

return _M
