{ 
    apiSuccess: (if .responses|has("succeeded") then .responses|.succeeded else false end), 
    errors: .responses|.messages, 
    responses: (if (.responses|.succeeded and .result) then (
        [ 
            if (.responses|.result|type == "object") then (.result | 
            { 
                last_name: (.lastName), 
                first_name: (.firstName), 
                cif:.id , tin: ((.taxId) // null), 
                tin_type: (if .taxIdType == "ITIN" then "TIN" else .taxIdType end), 
                work_phone:((.businessPhone) // null), 
                email:((.email) // null), 
                naics_code:((.naicsCode) // null), 
                address: { 
                    city:.homeAddress.city, 
                    address_line_1:.homeAddress.street1, 
                    address_line_2:.homeAddress.street2, 
                    zip_code:.homeAddress.postalCode, 
                    country:.homeAddress.countryCode, 
                    state:.homeAddress.stateCode 
                }
            })
            elif (.responses|.result|type == "array" ) then (.responses|.result[] | { 
                last_name: (.lastName), 
                first_name: (.firstName), 
                cif : .id , 
                tin: ((.taxId) // null), 
                tin_type: (if .taxIdType == "ITIN" then "TIN" else .taxIdType end), 
                work_phone:((.businessPhone) // null), 
                email:((.email) // null), 
                naics_code:((.naicsCode) // null), 
                address: { 
                    city:.homeAddress.city, 
                    address_line_1:.homeAddress.street1, 
                    address_line_2:.homeAddress.street2, 
                    zip_code:.homeAddress.postalCode, 
                    country:.homeAddress.countryCode, 
                    state:.homeAddress.stateCode 
                }
            })  else [{}] end 
        ]) 
        else [{}] end
    ) 
}