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
        responses: ( if $success and $root.responses.result
            then $root.responses.result | {
                collateralId: (.id // null)
            }
            else null
            end
        ) 
    }
)