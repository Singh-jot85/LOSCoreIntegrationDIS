( 
    .loan_relations[0] | { 
        FullName: (.full_name // null),
        FirstName: (.first_name // ""),
        MiddleName: (.middle_name // ""),
        LastName: (.last_name // ""),
        NameSuffix: (.suffix // ""),
        BusinessName: (.business_name // ""),
        StreetAddr1: "27 W. 24th St.",
        StreetAddr2: "",
        City: "New York",
        StateCode: "NY",
        PostalCode: "67899",
        CntryType: "US",
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
        ReqLegalEntityType: "true" 
    } 
)