{ 
    apiSuccess: (if .responses| has("succeeded") then .responses|.succeeded else false end), 
    errors: ((.responses|.messages) // null), 
    responses: (if .responses|.succeeded then {customerid:.responses.result.id} else null end) 
}