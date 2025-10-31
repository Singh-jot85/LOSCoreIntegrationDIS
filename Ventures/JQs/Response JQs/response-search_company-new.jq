{ 
    apiSuccess: (if .responses|has("succeeded") then .responses|.succeeded else false end), 
    errors: .responses|.messages, 
    responses: (if .responses|.succeeded and .result then 
        [ if (.result|type == "object") then .result | 
            { 
                cif: ((.id) // null),
                business_name: ((.name) // null),
                entity_type: ((.entityType) // null),
                tin: ((.taxId) // null), 
                tin_type: (if .taxIdType == "ITIN" then "TIN" else .taxIdType end), 
                work_phone:((.businessPhone) // null), 
                email:((.email) // null), 
                naics_code:((.naicsCode) // null),
                business_established_date: ((.establishedDate) //null),
                owner_establishment_date: ((.currentOwnershipEstablishedDate) //null),
                relation_addresses: { 
                    city:.address.city, 
                    address_line_1:.address.street1, 
                    address_line_2:.address.street2, 
                    zip_code:.address.postalCode, 
                    country:.address.countryCode, 
                    state:.address.stateCode 
                }
            } 
        elif .responses | .result|type == "array" then .responses|.result[] | 
            { 
                cif: ((.id) // null),
                business_name: ((.name) // null),
                entity_type: ((.entityType) // null),
                tin: ((.taxId) // null), 
                tin_type: (if .taxIdType == "ITIN" then "TIN" else .taxIdType end), 
                work_phone:((.businessPhone) // null), 
                email:((.email) // null), 
                naics_code:((.naicsCode) // null),
                business_established_date: ((.establishedDate) //null),
                owner_establishment_date: ((.currentOwnershipEstablishedDate) //null),
                relation_addresses: { 
                    city:.address.city, 
                    address_line_1:.address.street1, 
                    address_line_2:.address.street2, 
                    zip_code:.address.postalCode, 
                    country:.address.countryCode, 
                    state:.address.stateCode 
                }
            } 
        else null end 
        ] 
    else null end
    ) 
}