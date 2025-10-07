( .responses | 
    { 
        apiSuccess: (if .Output.Responses[0].WasSuccessful then .Output.Responses[0].WasSuccessful else false end),
        errors: .Output.UserAuthentication.Errors[0].ErrorMessage,
        responses: ( .Output.Responses[] | ( if .WasSuccessful and .Persons 
            then (.Persons[] | [
                { 
                    cif: .PersonNumber,
                    customer_details: 
                    { 
                        first_name: .FirstName,
                        middle_name: ( .MiddleName // ""),
                        last_name: .LastName,
                        tin: .TaxId 
                    } 
                }
            ]) 
            else null 
            end ) 
        )
    }
)