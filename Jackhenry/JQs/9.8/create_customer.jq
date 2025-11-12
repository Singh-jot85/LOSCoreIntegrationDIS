( 
    .loan_relations[0] | { 
        # flags
        ISSOLEPROP: ( // false),        

        ComName: (.full_name // null),
        FirstName: (.first_name // ""),
        MiddleName: (.middle_name // ""),
        LastName: (.last_name // ""),
        NameSuffix: (.suffix // ""),
        LegalName: (.business_name // ""),

        StreetAddr1: (.relation_addresses[0].address_line_1 // null),
        StreetAddr2: (.relation_addresses[0].address_line_2 // null),
        City: (.relation_addresses[0].city // null),
        StateCode: (.relation_addresses[0].state // null),
        PostalCode: (.relation_addresses[0].zip_code // null),
        DlvryPt: (.relation_addresses[0].zip_code_plus4 // null),

        NAICSCode: (.naics_code // ""),
        CustType: ( if .party_type == "individual" then "Y" else "N" end),
        BirthDt: (if .party_type == "individual" then .dob else "" end),
        EmplName: (if .party_type == "individual" and .naics_code == null then "Six Trees Capital, LLC" else "" end),
        OccType: (if .party_type == "individual" and .naics_code == null then "Account Manager" else "" end),
        EmailAddr: (.email // ""),
        PhoneType: (if .party_type == "individual" then "Home Cell Phone" else "Business Phone" end),
        PhoneNumDsp: (.work_phone // ""),
        TINCode: (if .party_type == "individual" then "I" else "B" end),
        TaxId: .tin,
        ReqLegalEntityType: "true",
        ErrOvrRds: [410023, 410050, 410059, 410079, 410017],
    } 
)