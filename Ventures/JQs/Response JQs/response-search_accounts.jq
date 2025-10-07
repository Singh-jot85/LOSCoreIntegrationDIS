{
  apiSuccess: (if .responses|has("succeeded") then .responses|.succeeded else false end), 
  errors: .responses|.messages,
  responses: (
    if .responses|.succeeded and .result then 
        if (.responses.result | type == "array") then 
            [.responses.result[]]
        elif (.responses.result|type == "object") then 
            [.responses.result]
        else null end
  else null end)
}