{ 
    firstName: ((.loan_relations[0].first_name) // null),
    lastName: ((.loan_relations[0].last_name) // null),
    middleName: ((.loan_relations[0].middle_name) // null),
    businessPhone: ((.loan_relations[0].work_phone|tostring) // null),
    homePhone: ((.loan_relations[0].home_phone|tostring) // null),
    mobilePhone: ((.loan_relations[0].cell_phone|tostring) // null),
    taxId: ((.loan_relations[0].tin) // null),
    taxIdType: ((if .loan_relations[0].tin_type == "TIN" then "ITIN" else .loan_relations[0].tin_type end) // null),
    dateOfBirth: ((.loan_relations[0].dob) // null),
    email: ((.loan_relations[0].email) // null),
    homeAddress: (if .loan_relations[0].relation_addresses|length>0 then (.loan_relations[0].relation_addresses[0] |
        {
            city: ((.city) // null),
            street1: ((.address_line_1) // null),
            street2: ((.address_line_2) // null),
            postalCode: (.zip_code // null),
            countryCode: ((.country) // null),
            stateCode: ((.state) // null)
        }) else {} end),
    businessAddress:{}
}