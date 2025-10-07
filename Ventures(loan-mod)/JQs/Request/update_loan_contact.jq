(
{
  contact: {
    firstName: .loan_relations[0].first_name,
    lastName: .loan_relations[0].last_name,
    businessPhone: (.loan_relations[0].work_phone | tostring | if length == 10 then "\(.[0:3])-\(.[3:6])-\(.[6:10])" else . end),
    homePhone: (.loan_relations[0].home_phone | tostring | if length == 10 then "\(.[0:3])-\(.[3:6])-\(.[6:10])" else . end),
    mobilePhone: (.loan_relations[0].cell_phone | tostring | if length == 10 then "\(.[0:3])-\(.[3:6])-\(.[6:10])" else . end),
    taxId: .loan_relations[0].formatted_tin,
    taxIdType: .loan_relations[0].tin_type,
    citizenship: (if .loan_relations[0].us_citizenship == true then "USCitizen" else "USCitizen" end),
    dateOfBirth: .loan_relations[0].dob,
    email: .loan_relations[0].email,
    homeAddress: (.loan_relations[0].relation_addresses[] | select(.address_type == "permanent") | {
      city: .city,
      street1: .address_line_1,
      street2: .address_line_2,
      postalCode: "\(.zip_code)+\(.zip_code_plus4)",
      countryCode: (if .country == "" then "US" else .country end),
      stateCode: .state
    })
  }
}
)