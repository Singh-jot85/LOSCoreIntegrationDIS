{
    apiSuccess: (if has("apiSuccess") then .apiSuccess else false end),
    errors: (
        (if .apiSuccess == false and .errors then (
            {
                "errorMsg": (if .errors.errorMsg|type == "string" then .errors.errorMsg elif .errors.errorMsg | has("InnerException") then .errors.errorMsg.InnerException.InnerException.Message else .errors.errorMsg.title end), 
                "errorNum": (if .errors|has("errorNum") then .errors.errorNum else null end)
            }
        ) else null end
        ) // null
    ),
    responses: (if .apiSuccess then 
        {
            accountDetails:.responses
        } else null end
    ) 
}