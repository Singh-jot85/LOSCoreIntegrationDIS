{
	loanId: (.loan_number // null),
	contact: .loan_relations[0] | {
		firstName: (.first_name // null),
		lastName: (.last_name // null),
		businessPhone: ((.work_phone | tostring) // null),
		homePhone: ((.home_phone | tostring) // null),
		mobilePhone: ((.cell_phone | tostring) // null),
		taxId: (.tin // null),
		taxIdType: (.tin_type // null),
		citizenship: (
			if .us_citizenship == true 
				then "USCitizen" 
			else "" end // null
		),
		dateOfBirth: (.dob // null),
		email: (.email // null),
		homeAddress: ( .relation_addresses[]
			| select(.address_type == "permanent") 
			| {
				city: ((.city) // null),
				street1: ((.address_line_1) // null),
				street2: ((.address_line_2) // null),
				postalCode: (.zip_code // null),
				countryCode: ((.country) // null),
				stateCode: ((.state) // null)
			}
		)
	},
	memberOf: ( .loan_relations[0] | if(.entity_type == "sole_proprietor") 
		then [ {
			entityName: ( 
				if .dba_name and .dba_name !="" 
					then .dba_name 
				else .first_name + (if (.middle_name and .middle_name != "" )
					then " " + .middle_name 
					else "" end
				) + " " + .last_name end
			),
			ownershipPercentage: 100,
			signer: (.is_signer),
			controllingMember: (.is_ben_owner_by_control) 
		}] 
		else[{ 
			entityName: (
				if .memberof 
					then .memberof 
				else (if .entity_type == "sole_proprietor" 
					then .borrower_name 
					else empty end
				) end
			),
			ownershipPercentage: .ownership_percentage,
			signer: (.is_signer),
			controllingMember: (.is_ben_owner_by_control) 
		}] 
		end
	)
}