(. as $root| ({
    apiSuccess: (
        $root.apiSuccess
        and (all($root.responses.Output.Responses[]; .WasSuccessful))
        and (all($root.responses.Output.Responses[].AllotmentResponses[]; .WasSuccessful))
    )
} | .apiSuccess as $success | 
    {
        apiSuccess: $success,
        errors: ( if ($success | not)
            then $root.errors | {
                errorMsg: (.errorMsg? // "An error occurred while making request."),
                errorNum: (.errorNum? // 500)
            }
            else null
            end
        ),
        responses: ( if $success
            then [$root.responses.Output.Responses[].AllotmentResponses[] | {
                allotment_number: .AllotmentNumber,
                payments_account_id: .AccountNumber
            }]
            else null
            end
        )
    }
))