( .responses | 
    { 
        apiSuccess: ( if .Output.Responses[0].WasSuccessful then .Output.Responses[0].WasSuccessful else false end ),
        errors: .Output.UserAuthentication.Errors[0].ErrorMessage,
        responses: ( .Output.Responses[] | if .WasSuccessful and .Organizations 
            then .Organizations[] | [ { 
                cif: .OrganizationNumber,
                customer_details: { 
                    org_name: .OrganizationName,
                    tin: .OrganizationTaxIds[0].TaxId 
                } 
            }]
            else null
            end
        )
    } 
)