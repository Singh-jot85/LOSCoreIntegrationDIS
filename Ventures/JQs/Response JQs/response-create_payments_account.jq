{
    apiSuccess: (if .responses | has("succeeded") then .responses | .succeeded else false end),
    errors: ((.responses | .messages) // null),
    responses: (if .responses | .succeeded then {payments_account_id: .responses.result.id} else null end)
}