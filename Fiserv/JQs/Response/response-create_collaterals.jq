{
    apiSuccess: (.apiSuccess and all(.responses.Output.Responses[]; .WasSuccessful) // false),
    errors:( if ((.apiSuccess and all(.responses.Output.Responses[]; .WasSuccessful) // false) | not)
        then {
            errorsNum: (.responses.Output.Responses[0].Errors[0].ErrorNumber // 400),
            errorMsg: (.responses.Output.Responses[0].Errors[0].ErrorMessage // "Something went wrong")
        }
        else null
        end
    ),
    responses: (if (.responses.Output.Responses[0].CollateralPropertyList) 
        then [ .responses.Output.Responses[].CollateralPropertyList[] | 
        { 
            collateralId: .PropertyNumber 
        }]
        else null
        end
    )
}
