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
	loanId: (.loan_number // null),
	borrower: false,
	association: (
		if .loan_relations[0].is_primary_borrower
			then "Operating Company" 
		else "Affiliate" 
		end
	),
	primary: (.loan_relations[0].is_primary_borrower // null),
	guaranteeType: (
		if (.loan_relations[0].ownership_percentage // "0" | tonumber ) > 20 
			then "Unsecured Full" 
		else "Unsecured Limited" 
		end // null
	),
	dbaName: (.loan_relations[0].dba_name // null),
	employeeCount: (.loan_relations[0].number_of_employees // null),
	annualRevenue: (.loan_relations[0].details.annual_business_revenue // null),
	company: ( .loan_aggregator as $aggregators
		| .loan_relations[0] 
		| {
			name: (.business_name // null),
			role: "LoanEntity",
			entityType: ($entityType[.entity_type] // null),
			businessPhone: (
				if .work_phone 
					then (.work_phone | tostring)
				elif .cell_phone 
					then (.cell_phone | tostring)
				else (.home_phone | tostring )
				end // null
			),
			email: (.email? // null),
			website: null,
			taxId: (.formatted_tin? // null),
			taxIdType: (.tin_type? // null),
			dunsNumber: null,
			address: ( (.details.mailing_address_flag // false) as $mailingAddressFlag
				| .relation_addresses[] 
				| select(.address_type == "mailing" or ($mailingAddressFlag and .address_type=="permanent"))
				| { 
					city: (.city // null),
					street1: (.address_line_1 // null),
					street2: (.address_line_2 // null),
					postalCode: "",
					countryCode: (.country // null),
					stateCode: (.state // null)
				} // null
			),
			establishedDate: ( .business_established_date // null),
			currentOwnershipEstablishedDate: ( .business_established_date // null),
			stateOfFormation: (.state_of_establishment // null),
			naicsCode: ( 
				if .naics_code 
					then .naics_code | tostring 
				else null 
				end 
			),
			creditScore: (( .tin as $relationTin 
				| $aggregators[]
				| select(.aggregator_type == "fico" and .is_latest == true) 
				| .details.fico.principals[] 
				| select(.SSN == $relationTin) 
				| .ficoScore | tonumber) // null
			),
			creditScoreDate: (( $aggregators[]
				| select(.aggregator_type == "fico" and .is_latest == true) 
				| (
					if .modified 
						then .modified | split("T")[0] 
					else "" 
					end
				)) // null
			)
		} // {}
	),
}
)