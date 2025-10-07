(
(
    {
        "single_member_llc":"Limited Liability Company Single Member",
        "sole_proprietor":"Sole Proprietorship",
        "partnership":"Partnership",
        "llc":"Limited Liability Company",
        "llc_as_s_corp":"Limited Liability Company",
        "llc_as_c_corp":"Limited Liability Company",
        "llc_as_partnership":"Limited Liability Partnership",
        "s_corp":"S Corporation",
        "c_corp":"C Corporation"
    }
) as $entityType |
{
    name: (.loan_relations[0].business_name // null), 
    entityType:$entityType[.loan_relations[0].entity_type] ,
    businessPhone: (if .loan_relations[0].work_phone then .loan_relations[0].work_phone|tostring elif .loan_relations[0].cell_phone then .loan_relations[0].cell_phone|tostring else .loan_relations[0].home_phone|tostring end // null),
    email: (.loan_relations[0].email // null),
    taxId: (.loan_relations[0].tin // null),
    taxIdType: ( if .loan_relations[0].tin_type == "TIN" then "ITIN" else .loan_relations[0].tin_type end // null),
    establishedDate: (.loan_relations[0].business_established_date // null),
    naicsCode: ( if .loan_relations[0].naics_code then .loan_relations[0].naics_code | tostring else null end ),
    address: ( if .loan_relations[0].relation_addresses | length > 0 then ( .loan_relations[0].relation_addresses[0] | 
        { 
            city: (.city // null),
            street1: (.address_line_1 // null),
            street2: (.address_line_2 // null),
            postalCode: "",
            countryCode: (.country // null),
            stateCode: (.state // null)
        }) 
        else {} end
    ) 
}
)