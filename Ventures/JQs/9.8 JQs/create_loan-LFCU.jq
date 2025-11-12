(
    ({
        "Purchase Commercial Real Estate": "Purchase Commercial Real Estate",
        "Improvement to Leased Space": "Improvements to Leased Space",
        "Purchase Equipment": "Purchase Equipment",
        "Purchase Furniture and Fixtures": "Purchase Furniture and Fixtures",
        "Purchase Inventory": "Purchase Inventory",
        "Debt Refinance": "Debt Refinance",
        "Business Acquisition": "Business Acquisition",
        "Working Capital": "Working Capital",
        "Purchase Vehicle(s)": "Purchase Vehicle(s)",
        "Start Up Financing": "Start Up Financing"
    }) as $purposeType |
    ({
        "Purchase Land only": "Purchase Of Land",
        "Purchase Land and improvements": "Purchase Land & Building",
        "Construct a Building": "Construct a Building",
        "Purchase Equipment": "Equipment",
        "SBA Guaranty Fee": "Soft Cost (Packaging and closing cost)",
        "Purchase Furniture and Fixtures": "Fixtures",
        "Other": "Other Cost",
        "Add an Addition to an Existing Building": "Building Addition",
        "Purchase Improvements only": "Purchase Improvement",
        "Make Renovations to an Existing Building": "Building Renovation",
        "Leasehold Improvements": "Building Leasehold Improvements",
        "Pay Notes Payable - not Same Institution Debt": "Pay Notes Payable - NOT Same Institution Debt",
        "Pay Notes Payable - Same Institution Debt": "Pay Notes Payable - Same Institution Debt",
        "Pay Off Interim Construction Loan": "Pay Off Interim Construction Loan",
        "Pay Off Lender's Interim Loan": "Pay Off Lender's Interim Loan",
        "Purchase Inventory": "Purchase Inventory",
        "Pay Trade or Accounts Payable": "Pay Trade or Accounts Payable",
        "Purchase Business - Stock Purchase": "Purchase Business (Change of Ownership)",
        "Purchase Business - Asset Purchase": "Purchase Business (Change of Ownership)",
        "Refinance SBA Loan - not Same Institution Debt": "Refinance SBA Loan – NOT Same Institution Debt",
        "Working Capital": "Working Capital",
        "Refinance SBA Loan - Same Institution Debt": "Refinance SBA Loan – Same Institution Debt"
    }) as $useOfProceedType | 
    ({
        "all_business_assets": "Business Assets",
        "Equipment": "Equipment",
        "machinery_and_equipment": "Equipment",
        "commercial_real_estate": "Commercial Real Estate",
        "Motor Vehicle": "Automobile",
        "vehicles": "Automobile",
        "life_insurance": "Life Insurance",
        "All Assets": "Business Assets",
        "all_assets": "Business Assets",
        "inventory_accounts_receivable": "Inventory",
        "other": "Other",
        "cash_and_equivalents": "Other",
        "furniture_fixtures_equipment": "Furniture and Fixtures",
        "assignment_of_leases": "Assignment of Leases & Rents",
        "land": "Ground Lease (Land Only No Improvements)"
    }) as $collateralType |
    ({
        "SB_TL": "Conventional Term Loan_Variable",
        "SB_LOC": "Conventional LOC_Variable",
        "EL_TL": "SBA EXPRESS TERM_VARIABLE",
        "EL_LOC": "SBA EXPRESS LOC_VARIABLE"
    }) as $varialbleLoanTypes |
    ({
        "SB_TL": "Conventional Term Loan",
        "SB_LOC": "Conventional LOC",
        "EL_TL": "SBA EXPRESS TERM",
        "EL_LOC": "SBA EXPRESS LOC"
    }) as $fixedLoanTypes |
    (
        ["EL_LOC", "EL_TL", "7A_TL", "504_TL", "MARC_7A_LOC", "MARC_7A_TL"]
    ) as $SBAproductCodes | 

{ 
    fundedDate: (.funding_date // null),
    sbaLoanNumber: (.product.product_code as $productCode | 
        if ($SBAproductCodes | index($productCode) != null)
            then (.sba_number // null)
        else (.application_number // null | tostring)
        end
    ),
    sbaApplicationNumber: (.sba_loan_app_number // null),
    referenceNumber: (.application_number // null | tostring),
    purposeType: (if $purposeType[.loan_purpose] then $purposeType[.loan_purpose] else "Other" end) ,
    loanTermMonths: (.loan_approval.approved_term // null),
    submittalDate: (if .submitted_date then .submitted_date | split("T")[0] else "" end),
    impactWomanOwnedBusiness: .cra_female_owned_business,
    impactVeteranOwnedBusiness: (if .details.boarding_details.veteran_owned_business == "yes" or .details.boarding_details.veteran_owned_business == "Yes" then true else false end),
    impactMinorityOwnedBusiness: .cra_minority_owned_business,
    loanType: ( .product.product_code as $productCode | .loan_approval.approved_rate_type as $rateType |
        if ($rateType == "Fixed")
            then if ($productCode == "7A_TL" and .loan_amount>500000 )
                    then "SBA 7(a)"
                elif ($productCode == "7A_TL")
                    then "SMALL SBA 7(a)"
                else ($fixedLoanTypes[.product.product_code] // null)
                end
        elif ($rateType == "Variable")
            then if ($productCode == "7A_TL" and .loan_amount>500000 )
                    then "SBA 7(a)_VARIABLE"
                elif ($productCode == "7A_TL")
                    then "SMALL SBA 7(a)_VARIABLE"
                else ($varialbleLoanTypes[.product.product_code] // null)
                end
        else null
        end
    ),
    loanStatus: "Funded",
    loanAmount: (.approved_amount // null),
    approvalDate: (.loan_decisioned_at // null),
    closingDate: (.closing_date // null),
    sbaProcessingMethodCode: (
        if (.product.product_code | IN("EL_LOC","EL_TL","7A")) 
        then "7AG" 
        else null 
        end
    ),
    impactLmi: (.details.etran_community_advantage.low_to_moderate_community),
    sbssScore: (if .sbss_score then .sbss_score | tonumber else "" end),
    sbssScoreDate: (try (.loan_interfaces[] | select(.interface_type == "fico" and .is_latest == true) | .details.fico_data.FI_LiquidCredit.timestamp | split(" ")[0] | strptime("%Y%m%d") | strftime("%Y-%m-%d") ) //null) ,
    riskRatingGrade: .risk_rating,
    riskRatingDate: (if .uw_completion_date then .uw_completion_date | split("T")[0] else "" end),
    riskRatingReviewerContactId: .environment_values.lc_user_id ,
    impactJobsCreatedByLoan: ((
        .loan_relations[] 
        | select(.is_primary_borrower == true) as $primaryBorrower
        | if ( ($primaryBorrower.questionaire_responses | length) != 0 )
            then ( $primaryBorrower.questionaire_responses[0].responses.jobs_created | tonumber )
        else null
        end )
    ),
    impactJobsRetainedByLoan: (
        ( .loan_relations[] 
        | select(.is_primary_borrower == true) as $primaryBorrower
        | if ( ($primaryBorrower.questionaire_responses | length) != 0 )
            then .questionaire_responses[0].responses.jobs_saved | tonumber 
        else null
        end )
    ),
    achAccountName: (.loan_relations[] | select(.is_primary_borrower==true) | if(.full_name == .business_name) then .full_name else (if .title and .title != "" then .title + " " + .first_name else .first_name end) + (if .middle_name and .middle_name != "" then " " + .middle_name else "" end) + " " + (if .suffix and .suffix != "" then .last_name + " " + .suffix else .last_name end) end // null),
    achAccountNumber: .bank_details.account_number, 
    achRoutingNumber: .bank_details.routing_number,
    achAccountType: .bank_details.account_type,
    impactEmpowermentZoneEnterpriseCommunity: (.details.etran_community_advantage.empowerment_zone),
    impactHubZone: (.details.etran_community_advantage.hub_zone),
    impactPromiseZone: (.details.etran_community_advantage.promise_zone),
    impactRural: (.loan_relations[] | select(.is_primary_borrower == true) | .details.rural_zone),
    impactOpportunityZone: (.details.etran_community_advantage.opportunity_zone),
    impactLowIncomeWorkforce: (.details.etran_community_advantage.resides_in_low_income),
    impactSbaVeteransAdvantage: (.details.etran_community_advantage.eligibility_for_SBA_veterans),
    collateralAnalysisNarrative: "Federal Flood Insurance if business location or collateral falls in a special flood hazard area, Worker's Compensation Insurance - upon hire of W-2 employees, Business Personal Property Insurance, full replacement costs, General Business Liability Insurance",
    keyManInsuranceNarrative: "General Lending Guidelines do not require Key Man Life and Disability insurance for small business loans $350,000 or less.",
    first2Years: ( 
        (.submitted_date | capture("^(?<date>\\d{4}-\\d{2}-\\d{2})").date) as $sub
        | (.loan_relations[] | select(.is_primary_borrower).business_established_date) as $est
        | ($sub | capture("(?<y>\\d{4})-(?<m>\\d{2})-(?<d>\\d{2})")) as $p
        | $est < (((($p.y|tonumber)-2)|tostring) + "-" + $p.m + "-" + $p.d)
    ),
    officeId: (
        if (.details.boarding_details.branch_code )
            then .details.boarding_details.branch_code | tonumber 
        else null 
        end
    ),
    interestRatePercent: .loan_approval.approved_rate,
    sop: "50 10 7.1",
    billingContactMethod: "Email",
    billingEmail: (.loan_relations[] | select(.is_primary_borrower == true) | .email),
    billingName: (.loan_relations[] | select(.is_primary_borrower == true) | .business_name),
    primaryContactId: (if .primary_contact_id then .primary_contact_id | tonumber else null end),
    referrals: [ 
        { 
            contactId:  .environment_values.lc_user_id,
            referralTypeId: 36,
            fee1Description: (.fees[] | select(.fee_setup.fee.fee_code == "express_loan_packaging_fee") | .fee_setup.fee.fee_name // null),
            fee1Amount: (.fees[] | select(.fee_setup.fee.fee_code == "express_loan_packaging_fee") | .approved_fee_amount // null),
            fee1PaidBy: "Applicant",
            fee3Description: (.fees[] | select(.fee_setup.fee.fee_code == "broker_or_referral_fee") | .fee_setup.fee.fee_name // null),
            fee3Amount: (.fees[] | select(.fee_setup.fee.fee_code == "broker_or_referral_fee") | .approved_fee_amount // null),
            fee3PaidBy: "Lender" 
        } 
    ] ,
    expenses:[.funding_date as $fundingDate | .fees[] | select( .fee_setup.fee.fee_category == "origination") | 
        { 
            description:.fee_setup.fee.description,
            amount:.approved_fee_amount,
            date: ($fundingDate // null)
        }
    ] ,
    useOfProceeds: ( .uop_id_mapping as $UOPIdMapping | [ .use_of_proceed_details[] | 
        { 
            useOfProceedTypeId: (if .purpose and $useOfProceedType[.purpose] and $UOPIdMapping[$useOfProceedType[.purpose]] then $UOPIdMapping[$useOfProceedType[.purpose]] else $UOPIdMapping["Other Cost"] end),
            Amount:(.amount|gsub(",|\\s";"")|tonumber) ,
            Description: .name 
        } 
    ]),
    collaterals: ( 
        .approved_amount as $loan_amount 
        | .collateral_types_mapping as $CollateralTypesMapping 
        | .environment_values.lien_holder_id as $lienHolderCompanyId 
        | [ .loan_relations[] 
        | .collaterals[] 
        | { 
            collateralTypeId: (if .collateral_type and $collateralType[.collateral_type_verbose] and $CollateralTypesMapping[$collateralType[.collateral_type_verbose]] then $CollateralTypesMapping[$collateralType[.collateral_type_verbose]] else ( if .category and $collateralType[.category] and $CollateralTypesMapping[$collateralType[.category]] then $CollateralTypesMapping[$collateralType[.category]] else $CollateralTypesMapping["Other"] end) end),
            value:(if .collateral_value then .collateral_value else $loan_amount end),
            lienPosition:(if .lien_position == "first" then 1 elif .lien_position == "second" then 2 elif .lien_position == "third" then 3 elif .lien_position == "fourth" then 4 elif .lien_position == "fifth" then 5 elif .lien_position == "subordinate" then 2 else null end),
            uccFiled:.is_ucc_filing_applicable,
            liens:[ .lien_holders[] | 
                { 
                    lienHolderCompanyId: $lienHolderCompanyId ,
                    lienPosition:(if .lien_position == "first" then 1 elif .lien_position == "second" then 2 elif .lien_position == "third" then 3 elif .lien_position == "fourth" then 4 elif .lien_position == "fifth" then 5 else null end),
                    amount:.original_note_amount ,
                    Comment:(if .business_name and .business_name != "" then .business_name else .first_name + " " + .last_name end)
                } 
            ] 
        } 
    ] as $collaterals | $collaterals | map( . + {primary: (.value == ($collaterals | max_by(.value) | .value))} )),
    mailingAddress: ( .loan_relations[] | select(.is_primary_borrower == true) | .relation_addresses[] | select(.address_type == "mailing") | 
        { 
            city: .city,
            street1: .address_line_1,
            street2: .address_line_2,
            postalCode: .zip_code,
            countryCode: .country,
            stateCode: .state 
        } 
    ),
    projectAddress: ( .loan_relations[] 
        | select(.is_primary_borrower == true) 
        | .relation_addresses[] 
        | select(.address_type == "project") 
        | { 
            city: .city,
            street1: .address_line_1,
            street2: .address_line_2,
            postalCode: .zip_code,
            countryCode: .country,
            stateCode: .state 
        } 
    ),
    partners: [ 
        {
            contactId:  .environment_values.lc_user_id,
            roleType: "LoanOfficer"
        },
        {
            contactId:  .environment_values.lc_user_id,
            roleType: "LoanProcessor"
        },
        {
            contactId:  .environment_values.lc_user_id,
            roleType: "ClosingOfficer"
        },
        {
            contactId:  .environment_values.lc_user_id,
            roleType: "CreditAnalyst"
        },
        {
            contactId:  .environment_values.lc_user_id,
            roleType: "ClosingAnalyst"
        } 
    ],
    entities : ( [ .loan_entities[] | 
        ( if (.entity_type == "sole_proprietor") then { 
            primary: .is_primary_borrower,
            association: "Operating Company",
            guaranteeType: "Unsecured Limited",
            company: 
                {
                    name: ( if (.dba_name and .dba_name !="") then .dba_name else (if(.full_name == .business_name) then .business_name else (if .title then .title + " " + .first_name else .first_name end) + (if .middle_name and .middle_name != "" then " " + .middle_name else "" end) + " " + (if .suffix then .last_name + " " + .suffix else .last_name end) end // null) end ),
                    taxId: .tin,
                    taxIdType: .tin_type,
                    entityType: "Sole Proprietorship",
                    naicsCode: ( if .naics_code then .naics_code | tostring else null end ),
                    businessPhone: ((.work_phone|tostring) // null),
                    currentOwnershipEstablishedDate: .business_established_date
                } 
        } 
        else { 
            companyId: (if .external_customer_id then .external_customer_id | tonumber else "" end),
            borrower:true ,
            association:(if .is_primary_borrower then "Operating Company" else "Affiliate" end) ,
            annualRevenue:( .details.annual_business_revenue ),
            guaranteeType:(if .is_primary_borrower == false and .ownership_percentage>20 then "Unsecured Full" else "Unsecured Limited" end),
            employeeCount: (if .is_primary_borrower then .number_of_employees else 0 end),
            primary: .is_primary_borrower,
            forms: [ (if .questionaire_responses[0] then 
                { 
                    name: "SBA1919_2023",
                    form: 
                        { 
                            question1: (if .questionaire_responses[0].responses.epc == "Yes" then true else false end),
                            question2: (if .questionaire_responses[0].responses.defaulted == "Yes" then true else false end),
                            question3: (if .questionaire_responses[0].responses.other_business == "Yes" then true else false end),
                            question4: (if .questionaire_responses[0].responses.probation == "Yes" then true else false end),
                            question5: (if .questionaire_responses[0].responses.exporting == "Yes" then true else false end),
                            question7: (if .questionaire_responses[0].responses.gambling == "Yes" then true else false end),
                            question8: (if .questionaire_responses[0].responses.sba_employee == "Yes" then true else false end),
                            question9: (if .questionaire_responses[0].responses.sba_employee_2 == "Yes" then true else false end),
                            question10: (if .questionaire_responses[0].responses.government == "Yes" then true else false end),
                            question11: (if .questionaire_responses[0].responses.government_2 == "Yes" then true else false end),
                            question12: (if .questionaire_responses[0].responses.sba_council == "Yes" then true else false end),
                            question13: (if .questionaire_responses[0].responses.legal_action == "Yes" then true else false end) 
                        } 
                } else empty end) 
            ],
            company: 
                { 
                    name: ( 
                        (if (.dba_name and .dba_name != "") then .dba_name else ( if(.full_name == .business_name) then .full_name else (if .title and .title != "" then .title + " " + .first_name else .first_name end) + (if (.middle_name and .middle_name != "") then " " + .middle_name else "" end) + " " + (if (.suffix and .suffix != "") then .last_name + " " + .suffix else .last_name end )end) end )),
                    stateOfFormation: .state_of_establishment,
                    currentOwnershipEstablishedDate: .business_established_date 
                },
            memberOf: [ 
                { 
                    entityName: (if .memberof then .memberof else empty end),
                    ownershipPercentage: .ownership_percentage,
                    signer: (.is_signer),
                    controllingMember: (.is_ben_owner_by_control) 
                } 
            ] 
        } end ) 
    ] ),
    contacts: [ .loan_contacts[] as $loan_relations | 
        { 
            contactID: (if $loan_relations.external_customer_id != "" and $loan_relations.external_customer_id != null then $loan_relations.external_customer_id | tonumber else "" end),
            guaranteeType:(if $loan_relations.ownership_percentage>20 then "Unsecured Full" else "Unsecured Limited" end) ,
            contact:
                { 
                    firstName:(if $loan_relations.title and $loan_relations.title != "" then $loan_relations.title + " " + $loan_relations.first_name else $loan_relations.first_name end),
                    lastName:(if $loan_relations.suffix and $loan_relations.suffix != "" then $loan_relations.last_name + " " + $loan_relations.suffix else $loan_relations.last_name end),
                    creditScore:( try (.loan_aggregator[] | select(.aggregator_type == "fico" and .is_latest == true) | .details.fico.principals[] | select(.SSN == $loan_relations.tin) | .ficoScore | tonumber) //null),
                    creditScoreDate:(try (.loan_aggregator[] | select(.aggregator_type == "fico" and .is_latest == true) | (if .modified then .modified | split("T")[0] else "" end) ) // null) 
                },
            memberOf: ( if ($loan_relations.entity_type == "sole_proprietor") then [ 
                {
                    entityName: (if ($loan_relations.dba_name and $loan_relations.dba_name != "") then $loan_relations.dba_name else ( (if $loan_relations.title and $loan_relations.title != "" then $loan_relations.title + " " + $loan_relations.first_name else $loan_relations.first_name end) + (if ($loan_relations.middle_name and $loan_relations.middle_name != "") then " " + $loan_relations.middle_name else "" end) + " " + (if ($loan_relations.suffix and $loan_relations.suffix != "") then $loan_relations.last_name + " " + $loan_relations.suffix else $loan_relations.last_name end ) ) end ),
                    ownershipPercentage: 100,
                    jobTitle: "Proprietor",
                    signer: ($loan_relations.is_signer),
                    controllingMember: ($loan_relations.is_ben_owner_by_control) 
                } 
            ] else [ 
                { 
                    entityName: (if $loan_relations.memberof then $loan_relations.memberof else (if $loan_relations.entity_type == "sole_proprietor" then (if ($loan_relations.dba_name and $loan_relations.dba_name != "") then $loan_relations.dba_name else ( (if $loan_relations.title and $loan_relations.title != "" then $loan_relations.title + " " + $loan_relations.first_name else $loan_relations.first_name end) + (if ($loan_relations.middle_name and $loan_relations.middle_name != "") then " " + $loan_relations.middle_name else "" end) + " " + (if ($loan_relations.suffix and $loan_relations.suffix != "") then $loan_relations.last_name + " " + $loan_relations.suffix else $loan_relations.last_name end ) ) end ) else empty end) end),
                    ownershipPercentage: $loan_relations.ownership_percentage,
                    jobTitle: (
                        if $loan_relations.position == "Managing Member" 
                            then "Member/Manager" 
                        else $loan_relations.position
                        end // null
                    ),
                    signer: ($loan_relations.is_signer),
                    controllingMember: ($loan_relations.is_ben_owner_by_control) 
                } 
            ] end) 
        } 
    ] 
}
)