(
  ({
    "single_member_llc":"Limited Liability Company Single Member",
    "sole_proprietor":"Sole Proprietorship",
    "partnership":"Partnership",
    "llc":"Limited Liability Company",
    "llc_as_s_corp":"Limited Liability Company",
    "llc_as_c_corp":"Limited Liability Company",
    "llc_as_partnership":"Limited Liability Partnership",
    "s_corp":"S Corporation",
    "c_corp":"C Corporation"
  }) as $entityType | 
{
  company: {
    name: (.loan_relations[0].business_name? // null),
    entityType: ($entityType[.loan_relations[0].entity_type] // null),
    role: "LoanEntity",
    businessPhone: (.loan_relations[0].work_phone? | if . then tostring | if length == 10 then "\(.[0:3])-\(.[3:6])-\(.[6:10])" else . end else null end),
    email: (.loan_relations[0].email? // null),
    website: null,
    taxId: (.loan_relations[0].formatted_tin? // null),
    taxIdType: (.loan_relations[0].tin_type? // null),
    dunsNumber: null,
    address: (try (.loan_relations[0].relation_addresses[]? | select(.address_type == "mailing") | {
      city: .city?,
      street1: .address_line_1?,
      street2: .address_line_2?,
      postalCode: (if .zip_code_plus4? and .zip_code_plus4 != "" then "\(.zip_code?)+\(.zip_code_plus4)" else .zip_code? end),
      countryCode: (if .country? == "" then "US" else .country? end),
      stateCode: .state?
    }) // null),
    establishedDate: (.loan_relations[0].business_established_date? // null),
    currentOwnershipEstablishedDate: (.loan_relations[0].business_established_date? // null),
    stateOfFormation: (.loan_relations[0].state_of_establishment? // null),
    naicsCode: ( if .loan_relations[0].naics_code then .loan_relations[0].naics_code | tostring else null end ),
    creditScore: (try (.loan_aggregator[]? | select(.aggregator_type == "fico" and .is_latest == true) | .details.fico.principals[]? | select(.SSN == .loan_relations[0].tin?) | .ficoScore? | tonumber) // null),
    creditScoreDate: (try (.loan_aggregator[]? | select(.aggregator_type == "fico" and .is_latest == true) | (if .modified? then .modified | split("T")[0] else "" end)) // null)
  },
  association: (if .loan_relations[0].is_primary_borrower? then "Operating Company" else "Affiliate" end),
  primary: (.loan_relations[0].is_primary_borrower? // false),
  borrower: false,
  guaranteeType: (if (.loan_relations[0].ownership_percentage? | tonumber? // 0) > 20 then "Unsecured Full" else "Unsecured Limited" end),
  dbaName: (.loan_relations[0].dba_name? // null),
  employeeCount: (.loan_relations[0].number_of_employees? // null),
  annualRevenue: (.loan_relations[0].details.annual_business_revenue? // null)
}
)