(
    . as $root
    | (.apiSuccess and .responses.succeeded) as $success
    | {
        apiSuccess: $success,
        errors: ( if ($success | not)
            then .errors
            else null
            end
        ),
        responses: ( if $success 
            then {
                status: "success"
            }
            else null
            end
        ) 
    }
)