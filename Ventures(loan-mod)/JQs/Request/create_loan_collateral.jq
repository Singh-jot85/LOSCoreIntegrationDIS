({
    "Equipment": "Equipment",
    "machinery_and_equipment": "Equipment",
    "commercial_real_estate": "Commercial Real Estate",
    "Motor Vehicle": "Automobile",
    "vehicles": "Automobile",
    "life_insurance": "Life Insurance",
    "all_assets": "Business Assets",
    "all_business_assets": "Business Assets",
    "inventory_accounts_receivable": "Inventory",
    "other": "Other",
    "cash_and_equivalents": "Other",
    "furniture_fixtures_equipment": "Furniture and Fixtures",
    "assignment_of_leases": "Assignment of Leases & Rents",
    "land": "Ground Lease (Land Only No Improvements)"
}) as $collateralType |
(
. as $root | 
.collateral_types_mapping as $CollateralTypesMapping | 
.loan_collateral[0] as $collateral | 
    {
        loanId: ($root.loan_number // null),
        primary: false,
        collateralTypeId: ( $collateral | ( 
            if (
                .collateral_type 
                and $collateralType[.collateral_type_verbose] 
                and $CollateralTypesMapping[$collateralType[.collateral_type_verbose]] 
            )
                then $CollateralTypesMapping[$collateralType[.collateral_type_verbose]] 
            else ( 
                if (
                    .category 
                    and $collateralType[.category] 
                    and $CollateralTypesMapping[$collateralType[.category]] 
                )
                    then $CollateralTypesMapping[$collateralType[.category]] 
                else $CollateralTypesMapping["Other"] 
                end 
            ) 
            end)
        ),
        value: ($collateral.collateral_value // null),
        lienPosition: ( $collateral.lien_position // null),
        address: ($collateral.collateral_addresses[] 
            | select(.address_type == "permanent") 
            | {
				city: (.city // null),
				street1: (.address_line_1 // null),
				street2: (.address_line_2 // null),
				postalCode: (.zip_code // null),
				countryCode: (.country // null),
				stateCode: (.state // null)
			}
        ),
        uccFiled: $collateral.is_ucc_filing_applicable,
        liens: ( $collateral | ( 
            if (.lien_holders? | length > 0) 
                then [.lien_holders[] 
                    | { 
                        lienHolderCompanyId: 207029,
                        lienPosition: (
                            if .lien_position == "first" 
                                then 1 
                            elif .lien_position == "second" 
                                then 2 
                            elif .lien_position == "third" 
                                then 3 
                            elif .lien_position == "fourth" 
                                then 4 
                            elif .lien_position == "fifth" 
                                then 5 
                            else null 
                            end
                        ),
                        amount:.original_note_amount ,
                        Comment:(
                            if .business_name and .business_name != "" 
                                then .business_name 
                            else .first_name + " " + .last_name 
                            end
                        )
                    }]
            else null
            end )
        )
    }
)