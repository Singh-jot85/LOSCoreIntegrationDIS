(
    (
        .apiSuccess 
        and all(.responses.Output.Responses[]; .WasSuccessful)
    ) as $isSuccess |
    .responses | {
        apiSuccess: $isSuccess,
        errors: ( if ($isSuccess | not)
            then 
            {
                errorNum: (.Output.Responses[0].Errors[0].ErrorNumber // 400),
                errorMsg: (.Output.Responses[0].Errors[0].ErrorMessage // "Something went wrong")
            }
            else null
            end
        ),
        responses: ( if ($isSuccess and .Output.Responses[0].CollateralPropertyList)
            then [ .Output.Responses[0].CollateralPropertyList[] 
            | {
                collateralId: .PropertyNumber
            } ]
            else null
            end
        )
    }
)