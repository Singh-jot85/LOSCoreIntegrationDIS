from los.configurations.models import Configuration, OrganizationConfiguration

interfaces = {
    "ci_tenant_map": {
        "portfolio2": {
            "module": "core_integration.ventures.ventures_adapter",
            "adapter": "VenturesAdapter",
            "corebanking_name": "ventures"
        },
        "centierbank": {
            "module": "core_integration.csi.csi_adapter",
            "adapter": "CsiAdapter",
            "corebanking_name": "csi"
        },
        "lrtcapital": {
            "module": "core_integration.ventures.ventures_adapter",
            "adapter": "VenturesAdapter",
            "corebanking_name": "ventures"
        }
    },
    "ci-ventures-common": {
        "validation_spec": "{}",
        "request_body_spec": "{}",
        "response_body_spec": {
            "errors": {
                "errorMsg": "", 
                "errorNum": ""
            }, 
            "responses": "", 
            "apiSuccess": True
        },
    },
    "ci-ventures-entity-mapping":{
        "method_config": [
                {
                    "document_type": {
                        "method": "fetch_configuration_data",
                        "flavour": "DocumentType"
                    }
                },
                {
                    "custom_object": {
                        "method": "fetch_configuration_data",
                        "flavour": "CustomObject"
                    }
                },
                {
                    "custom_field": {
                        "method": "fetch_configuration_data",
                        "flavour": "CustomField"
                    }
                },
                {
                    "uop_purpose_types": {
                        "method": "fetch_configuration_data",
                        "flavour": "UseOfProceedType"
                    }
                },
                {
                    "collateral_types": {
                        "method": "fetch_configuration_data",
                        "flavour": "CollateralType"
                    }
                }
        ],
        "relation_types": [
            "borrower",
            "co_borrower",
            "owner"
        ],
        "create_customer": {
            "method_name": {
                "entity": "execute_create_company_request",
                "individual": "execute_create_contact_request"
            },
            "get_tranformed_config": {
                "entity": "create_company",
                "individual": "create_contact"
            }
        },
        "search_accounts": {},
        "search_customers": {
            "method_name": {
                "entity": "execute_search_company_request",
                "individual": "execute_search_contact_request"
            },
            "get_tranformed_config": {
                "entity": "search_company",
                "individual": "search_contact"
            }
        },
        "default_document_type": "APP MISCELLANEOUS"
    },
    "ci-ventures-search_contact":{
        "validation_spec": "{}",
        "request_body_spec": "{\n taxIdType: ((.loan_relations[] | (if .tin_type == \"TIN\" then \"ITIN\" else .tin_type end)) // null),\n taxId: ((.loan_relations[] | .tin) // null) \n}",
        "response_body_spec": "{ \n    apiSuccess: (if .responses|has(\"succeeded\") then .responses|.succeeded else false end), \n    errors: .responses|.messages, \n    responses: (if .responses|.succeeded and .result then \n        [ if (.result|type == \"object\") then .result | \n            { \n                last_name: (.lastName), \n                first_name: (.firstName), \n                cif:.id , tin: ((.taxId) // null), \n                tin_type: (if .taxIdType == \"ITIN\" then \"TIN\" else .taxIdType end), \n                work_phone:((.businessPhone) // null), \n                email:((.email) // null), \n                naics_code:((.naicsCode) // null), \n                address: { \n                    city:.homeAddress.city, \n                    address_line_1:.homeAddress.street1, \n                    address_line_2:.homeAddress.street2, \n                    zip_code:.homeAddress.postalCode, \n                    country:.homeAddress.countryCode, \n                    state:.homeAddress.stateCode \n                }\n            } \n        elif .responses | .result|type == \"array\" then .responses|.result[] | { \n            last_name: (.lastName), \n            first_name: (.firstName), \n            cif : .id , \n            tin: ((.taxId) // null), \n            tin_type: (if .taxIdType == \"ITIN\" then \"TIN\" else .taxIdType end), \n            work_phone:((.businessPhone) // null), \n            email:((.email) // null), \n            naics_code:((.naicsCode) // null), \n            address: { \n                city:.homeAddress.city, \n                address_line_1:.homeAddress.street1, \n                address_line_2:.homeAddress.street2, \n                zip_code:.homeAddress.postalCode, \n                country:.homeAddress.countryCode, \n                state:.homeAddress.stateCode \n            }\n        } \n        else null end \n        ] \n    else [{}] end\n    ) \n}",
        "request_body_spec_config": "{}",
        "response_body_spec_config": "{}"
    },
    "ci-ventures-search_company": {
        "validation_spec": "{}",
        "request_body_spec": "{\n taxIdType: ((.loan_relations[] | (if .tin_type == \"TIN\" then \"ITIN\" else .tin_type end)) // null),\n taxId: ((.loan_relations[] | .tin) // null) \n}",
        "response_body_spec": "{ \n    apiSuccess: (if .responses|has(\"succeeded\") then .responses|.succeeded else false end), \n    errors: .responses|.messages, \n    responses: (if .responses|.succeeded and .result then \n        [ if (.result|type == \"object\") then .result | \n            { \n                cif: ((.id) // null),\n                business_name: ((.name) // null),\n                entity_type: ((.entityType) // null),\n                tin: ((.taxId) // null), \n                tin_type: (if .taxIdType == \"ITIN\" then \"TIN\" else .taxIdType end), \n                work_phone:((.businessPhone) // null), \n                email:((.email) // null), \n                naics_code:((.naicsCode) // null),\n                business_established_date: ((.establishedDate) //null),\n                owner_establishment_date: ((.currentOwnershipEstablishedDate) //null),\n                relation_addresses: { \n                    city:.address.city, \n                    address_line_1:.address.street1, \n                    address_line_2:.address.street2, \n                    zip_code:.address.postalCode, \n                    country:.address.countryCode, \n                    state:.address.stateCode \n                }\n            } \n        elif .responses | .result|type == \"array\" then .responses|.result[] | \n            { \n                cif: ((.id) // null),\n                business_name: ((.name) // null),\n                entity_type: ((.entityType) // null),\n                tin: ((.taxId) // null), \n                tin_type: (if .taxIdType == \"ITIN\" then \"TIN\" else .taxIdType end), \n                work_phone:((.businessPhone) // null), \n                email:((.email) // null), \n                naics_code:((.naicsCode) // null),\n                business_established_date: ((.establishedDate) //null),\n                owner_establishment_date: ((.currentOwnershipEstablishedDate) //null),\n                relation_addresses: { \n                    city:.address.city, \n                    address_line_1:.address.street1, \n                    address_line_2:.address.street2, \n                    zip_code:.address.postalCode, \n                    country:.address.countryCode, \n                    state:.address.stateCode \n                }\n            } \n        else null end \n        ] \n    else [{}] end\n    ) \n}",
        "request_body_spec_config": "{}",
        "response_body_spec_config": "{}"
    },
    "ci-ventures-create_contact": {
        "validation_spec": "{}",
        "request_body_spec": "{\n taxIdType: ((.loan_relations[] | (if .tin_type == \"TIN\" then \"ITIN\" else .tin_type end)) // null),\n taxId: ((.loan_relations[] | .tin) // null) \n}",
        "response_body_spec": "{ \n    apiSuccess: (if .responses|has(\"succeeded\") then .responses|.succeeded else false end), \n    errors: .responses|.messages, \n    responses: (if .responses|.succeeded and .result then \n        [ if (.result|type == \"object\") then .result | \n            { \n                last_name: (.lastName), \n                first_name: (.firstName), \n                cif:.id , tin: ((.taxId) // null), \n                tin_type: (if .taxIdType == \"ITIN\" then \"TIN\" else .taxIdType end), \n                work_phone:((.businessPhone) // null), \n                email:((.email) // null), \n                naics_code:((.naicsCode) // null), \n                address: { \n                    city:.homeAddress.city, \n                    address_line_1:.homeAddress.street1, \n                    address_line_2:.homeAddress.street2, \n                    zip_code:.homeAddress.postalCode, \n                    country:.homeAddress.countryCode, \n                    state:.homeAddress.stateCode \n                }\n            } \n        elif .responses | .result|type == \"array\" then .responses|.result[] | { \n            last_name: (.lastName), \n            first_name: (.firstName), \n            cif : .id , \n            tin: ((.taxId) // null), \n            tin_type: (if .taxIdType == \"ITIN\" then \"TIN\" else .taxIdType end), \n            work_phone:((.businessPhone) // null), \n            email:((.email) // null), \n            naics_code:((.naicsCode) // null), \n            address: { \n                city:.homeAddress.city, \n                address_line_1:.homeAddress.street1, \n                address_line_2:.homeAddress.street2, \n                zip_code:.homeAddress.postalCode, \n                country:.homeAddress.countryCode, \n                state:.homeAddress.stateCode \n            }\n        } \n        else null end \n        ] \n    else [{}] end\n    ) \n}",
        "request_body_spec_config": "{}",
        "response_body_spec_config": "{}"
    },
    "ci-ventures-create_company":{
        "validation_spec": "{}",
        "request_body_spec": "{name: (.loan_relations[0].business_name // null), entityType:$entityType[.loan_relations[0].entity_type] ,\n businessPhone: (if .loan_relations[0].work_phone then .loan_relations[0].work_phone|tostring elif .loan_relations[0].cell_phone then .loan_relations[0].cell_phone|tostring else .loan_relations[0].home_phone|tostring end // null),\n email: (.loan_relations[0].email // null),\n taxId: (.loan_relations[0].tin // null),\n taxIdType: ( if .loan_relations[0].tin_type == \"TIN\" then \"ITIN\" else .loan_relations[0].tin_type end // null),\n establishedDate: (.loan_relations[0].business_established_date // null),\n naicsCode: ( if .loan_relations[0].naics_code then .loan_relations[0].naics_code | tostring else null end ),\n address: ( if .loan_relations[0].relation_addresses | length > 0 then ( .loan_relations[0].relation_addresses[0] | { city: (.city // null),\n street1: (.address_line_1 // null),\n street2: (.address_line_2 // null),\n postalCode: \"\",\n countryCode: (.country // null),\n stateCode: (.state // null)}) else {} end) }",
        "response_body_spec": "{ \n apiSuccess: (if .responses| has(\"succeeded\") then .responses|.succeeded else false end), \n errors: ((.responses|.messages) // null), \n responses: (if .responses|.succeeded then {customerid:.responses.result.id} else null end) \n}",
        "request_body_spec_config": "{\n \"entityType\":{\n \"single_member_llc\":\"Limited Liability Company Single Member\",\n \"sole_proprietor\":\"Sole Proprietorship\",\n \"partnership\":\"Partnership\",\n \"llc\":\"Limited Liability Company\",\n \"llc_as_s_corp\":\"Limited Liability Company\",\n \"llc_as_c_corp\":\"Limited Liability Company\",\n \"llc_as_partnership\":\"Limited Liability Partnership\",\n \"s_corp\":\"S Corporation\",\n \"c_corp\":\"C Corporation\"\n }\n}",
        "response_body_spec_config": "{}"
    },
    "ci-ventures-create_loan": {
        "validation_spec": "{}",
        "request_body_spec": "{ \n    sbaLoanNumber: .sba_number,\n    sbaApplicationNumber: .sba_loan_app_number,\n    referenceNumber: (.application_number // null | tostring),\n    purposeType: (if $purposeType[.loan_purpose] then $purposeType[.loan_purpose] else \"Other\" end) ,\n    loanTermMonths: (.loan_approval.approved_term // null),\n    submittalDate: (if .submitted_date then .submitted_date | split(\"T\")[0] else \"\" end),\n    impactWomanOwnedBusiness: .cra_female_owned_business,\n    impactVeteranOwnedBusiness: (\n        if (\n            .details.boarding_details.veteran_owned_business == \"yes\" \n            or .details.boarding_details.veteran_owned_business == \"Yes\"\n        )\n            then true \n        else false \n        end\n    ),\n    impactMinorityOwnedBusiness: .cra_minority_owned_business,\n    loanType: \"7A\",\n    loanStatus: \"Approved\",\n    loanAmount: (.approved_amount // null),\n    approvalDate: (.loan_decisioned_at // null),\n    closingDate: (.closing_date // null),\n    sbaProcessingMethodCode: \"7AG\",\n    impactLmi: .details.etran_community_advantage.low_to_moderate_community,\n    sbssScore: (if .sbss_score then .sbss_score | tonumber else null end),\n    sbssScoreDate:( try (.loan_interfaces[] | select(.interface_type == \"fico\" and .is_latest == true) | .details.fico_data.FI_LiquidCredit.timestamp | split(\" \")[0] | strptime(\"%Y%m%d\") | strftime(\"%Y-%m-%d\") ) //null) ,\n    riskRatingGrade: .risk_rating,\n    riskRatingDate: (if .uw_completion_date then .uw_completion_date | split(\"T\")[0] else \"\" end),\n    riskRatingReviewerContactId:236705 ,\n    impactJobsCreatedByLoan: ((\n        .loan_relations[] \n        | select(.is_primary_borrower == true) as $primaryBorrower\n        | if ( ($primaryBorrower.questionaire_responses | length) != 0 )\n            then ( $primaryBorrower.questionaire_responses[0].responses.jobs_created | tonumber )\n        else null\n        end )\n    ),\n    impactJobsRetainedByLoan: (\n        ( .loan_relations[] \n        | select(.is_primary_borrower == true) as $primaryBorrower\n        | if ( ($primaryBorrower.questionaire_responses | length) != 0 )\n            then .questionaire_responses[0].responses.jobs_saved | tonumber \n        else null\n        end )\n    ),\n    achAccountName: (.loan_relations[] | select(.is_primary_borrower==true) | if(.full_name == .business_name) then .full_name else (if .title and .title != \"\" then .title + \" \" + .first_name else .first_name end) + (if .middle_name and .middle_name != \"\" then \" \" + .middle_name else \"\" end) + \" \" + (if .suffix and .suffix != \"\" then .last_name + \" \" + .suffix else .last_name end) end // null),\n    achAccountNumber: .bank_details.account_number,\n    achRoutingNumber: .bank_details.routing_number,\n    achAccountType: .bank_details.account_type,\n    impactEmpowermentZoneEnterpriseCommunity: (.details.etran_community_advantage.empowerment_zone),\n    impactHubZone: (.details.etran_community_advantage.hub_zone),\n    impactPromiseZone: (.details.etran_community_advantage.promise_zone),\n    impactRural: (.details.etran_community_advantage.rural_zone),\n    impactOpportunityZone: (.details.etran_community_advantage.opportunity_zone),\n    impactLowIncomeWorkforce: (.details.etran_community_advantage.resides_in_low_income),\n    impactSbaVeteransAdvantage: (.details.etran_community_advantage.eligibility_for_SBA_veterans),\n    collateralAnalysisNarrative: \"Federal Flood Insurance if business location or collateral falls in a special flood hazard area, Worker's Compensation Insurance - upon hire of W-2 employees, Business Personal Property Insurance, full replacement costs, General Business Liability Insurance\",\n    keyManInsuranceNarrative: \"General Lending Guidelines do not require Key Man Life and Disability insurance for small business loans $350,000 or less.\",\n    first2Years: ( \n        (.submitted_date | capture(\"^(?<date>\\\\d{4}-\\\\d{2}-\\\\d{2})\").date) as $sub\n        | (.loan_relations[] | select(.is_primary_borrower).business_established_date) as $est\n        | ($sub | capture(\"(?<y>\\\\d{4})-(?<m>\\\\d{2})-(?<d>\\\\d{2})\")) as $p\n        | $est < (((($p.y|tonumber)-2)|tostring) + \"-\" + $p.m + \"-\" + $p.d)\n    ),\n    officeId: (if .details.boarding_details.branchCode then .details.boarding_details.branchCode | tonumber else null end),\n    interestRatePercent: .loan_approval.approved_rate,\n    sop: \"50 10 7.1\",\n    billingContactMethod: \"Email\",\n    billingEmail: (.loan_relations[] | select(.is_primary_borrower == true) | .email),\n    billingName: (.loan_relations[] | select(.is_primary_borrower == true) | .business_name),\n    primaryContactId: (if .primary_contact_id then .primary_contact_id | tonumber else null end),\n    referrals: [ \n        { \n            contactId: 236705,\n            referralTypeId: 36,\n            fee1Description: (.fees[] | select(.fee_setup.fee.fee_code == \"express_loan_packaging_fee\") | .fee_setup.fee.fee_name // null),\n            fee1Amount: (.fees[] | select(.fee_setup.fee.fee_code == \"express_loan_packaging_fee\") | .approved_fee_amount // null),\n            fee1PaidBy: \"Applicant\",\n            fee3Description: (.fees[] | select(.fee_setup.fee.fee_code == \"broker_or_referral_fee\") | .fee_setup.fee.fee_name // null),\n            fee3Amount: (.fees[] | select(.fee_setup.fee.fee_code == \"broker_or_referral_fee\") | .approved_fee_amount // null),\n            fee3PaidBy: \"Lender\" \n        }\n    ] ,\n    expenses:[.fees[] | select( .fee_setup.fee.fee_category == \"origination\") | { description:.fee_setup.fee.description,\n    amount:.approved_fee_amount,\n    date:(if .created then (.created | split(\"T\")[0]) else \"\" end)}] ,\n    useOfProceeds: ( .uop_id_mapping as $UOPIdMapping | [ .use_of_proceed_details[] | \n        { \n            useOfProceedTypeId: (if .purpose and $useOfProceedType[.purpose] and $UOPIdMapping[$useOfProceedType[.purpose]] then $UOPIdMapping[$useOfProceedType[.purpose]] else $UOPIdMapping[\"Other Cost\"] end),\n            Amount:(.amount|gsub(\",|\\\\s\";\"\")|tonumber) ,\n            Description: .name \n        } \n    ]),\n    collaterals:( \n        .approved_amount as $loan_amount\n        | .collateral_types_mapping as $CollateralTypesMapping \n        | [ .collaterals[] \n        | { \n            collateralTypeId: (if .collateral_type and $collateralType[.collateral_type_verbose] and $CollateralTypesMapping[$collateralType[.collateral_type_verbose]] then $CollateralTypesMapping[$collateralType[.collateral_type_verbose]] else ( if .category and $collateralType[.category] and $CollateralTypesMapping[$collateralType[.category]] then $CollateralTypesMapping[$collateralType[.category]] else $CollateralTypesMapping[\"Other\"] end) end),\n            value:(if .collateral_value then .collateral_value else $loan_amount end),\n            lienPosition:(if .lien_position == \"first\" then 1 elif .lien_position == \"second\" then 2 elif .lien_position == \"third\" then 3 elif .lien_position == \"fourth\" then 4 elif .lien_position == \"fifth\" then 5 elif .lien_position == \"subordinate\" then 2 else null end),\n            uccFiled:.is_ucc_filing_applicable,\n            liens:[ .lien_holders[] | \n                { \n                    lienHolderCompanyId:207029,\n                    lienPosition:(if .lien_position == \"first\" then 1 elif .lien_position == \"second\" then 2 elif .lien_position == \"third\" then 3 elif .lien_position == \"fourth\" then 4 elif .lien_position == \"fifth\" then 5 else null end),\n                    amount:.original_note_amount ,\n                    Comment:(if .business_name and .business_name != \"\" then .business_name else .first_name + \" \" + .last_name end)\n                } \n            ] \n        } ] as $collaterals | $collaterals | map( . + {primary: (.value == ($collaterals | max_by(.value) | .value))} )\n    ),\n    mailingAddress: ( [\n            .loan_relations[] \n            | select(.is_primary_borrower == true) \n            | (.details.mailing_address_flag // false) as $mailingAddressFlag \n            | .relation_addresses[] \n            | select(.address_type == \"mailing\" or ($mailingAddressFlag and .address_type==\"permanent\"))\n        ][0]\n        | { \n            city: .city,\n            street1: .address_line_1,\n            street2: .address_line_2,\n            postalCode: .zip_code,\n            countryCode: .country,\n            stateCode: .state \n        } \n    ),\n    projectAddress: ( [\n            .loan_relations[] \n            | select(.is_primary_borrower == true) \n            | (.details.project_address_flag // false) as $projectAddressFlag \n            | .relation_addresses[] \n            | select(.address_type == \"project\" or ($projectAddressFlag and .address_type==\"permanent\"))\n        ][0]\n        | { \n            city: .city,\n            street1: .address_line_1,\n            street2: .address_line_2,\n            postalCode: .zip_code,\n            countryCode: .country,\n            stateCode: .state \n        } \n    ),\n    partners: [ \n        {\n            contactId: 236705,\n            roleType: \"LoanOfficer\"\n        },\n        {\n            contactId: 236705,\n            roleType: \"LoanProcessor\"\n        },\n        {\n            contactId: 236705,\n            roleType: \"ClosingOfficer\"\n        },\n        {\n            contactId: 236705,\n            roleType: \"CreditAnalyst\"\n        },\n        {\n            contactId: 236705,\n            roleType: \"ClosingAnalyst\"\n        } \n    ],\n    entities : ( [ .loan_entities[] | ( if (.entity_type == \"sole_proprietor\") then { \n            primary: .is_primary_borrower,\n            association: \"Operating Company\",\n            guaranteeType: \"Unsecured Limited\",\n            company: \n                { \n                    name: ( \n                        if (.dba_name and .dba_name !=\"\") \n                            then .dba_name \n                        else (if .title and .title != \"\" then .title + \" \" + .first_name else .first_name end) + (if .middle_name and .middle_name != \"\" then \" \" + .middle_name else \"\" end) + \" \" + (if .suffix and .suffix != \"\" then .last_name + \" \" + .suffix else .last_name end)\n                        end \n                    ),\n                    taxId: .tin,\n                    taxIdType: .tin_type,\n                    entityType: \"Sole Proprietorship\",\n                    naicsCode: ( if .naics_code then .naics_code | tostring else null end ),\n                    businessPhone: ((.work_phone|tostring) // null),\n                    currentOwnershipEstablishedDate: .business_established_date\n                } \n        } \n        else {\n            companyId: (if .external_customer_id then .external_customer_id | tonumber else \"\" end),\n            borrower:true ,\n            association:(if .is_primary_borrower then \"Operating Company\" else \"Affiliate\" end) ,\n            annualRevenue:( .details.annual_business_revenue ),\n            guaranteeType:(if .is_primary_borrower == false and .ownership_percentage>20 then \"Unsecured Full\" else \"Unsecured Limited\" end),\n            employeeCount: (if .is_primary_borrower then .number_of_employees else 0 end),\n            primary: .is_primary_borrower,\n            forms: [ (if .questionaire_responses[0] then \n            { \n                name: \"SBA1919_2023\",\n                form: \n                    { \n                        question1: (if .questionaire_responses[0].responses.epc == \"Yes\" then true else false end),\n                        question2: (if .questionaire_responses[0].responses.defaulted == \"Yes\" then true else false end),\n                        question3: (if .questionaire_responses[0].responses.other_business == \"Yes\" then true else false end),\n                        question4: (if .questionaire_responses[0].responses.probation == \"Yes\" then true else false end),\n                        question5: (if .questionaire_responses[0].responses.exporting == \"Yes\" then true else false end),\n                        question7: (if .questionaire_responses[0].responses.gambling == \"Yes\" then true else false end),\n                        question8: (if .questionaire_responses[0].responses.sba_employee == \"Yes\" then true else false end),\n                        question9: (if .questionaire_responses[0].responses.sba_employee_2 == \"Yes\" then true else false end),\n                        question10: (if .questionaire_responses[0].responses.government == \"Yes\" then true else false end),\n                        question11: (if .questionaire_responses[0].responses.government_2 == \"Yes\" then true else false end),\n                        question12: (if .questionaire_responses[0].responses.sba_council == \"Yes\" then true else false end),\n                        question13: (if .questionaire_responses[0].responses.legal_action == \"Yes\" then true else false end) \n                    } \n            } else empty end) \n        ],\n        company: \n            { \n                name: ( .business_name // null),\n                stateOfFormation: .state_of_establishment,\n                currentOwnershipEstablishedDate: .business_established_date \n            },\n        memberOf: [ \n            { \n                entityName: (if .memberof then .memberof else empty end),\n                ownershipPercentage: .ownership_percentage,\n                signer: (.is_signer),\n                controllingMember: (.is_ben_owner_by_control) \n            } \n        ] \n    } end ) ] ),\n    contacts: [ .loan_contacts[] as $loan_relations |\n        {\n            contactID: (if $loan_relations.external_customer_id != \"\" and $loan_relations.external_customer_id != null then $loan_relations.external_customer_id | tonumber else \"\" end),\n            guaranteeType:(if $loan_relations.ownership_percentage>20 then \"Unsecured Full\" else \"Unsecured Limited\" end) ,\n            contact: \n                { \n                    firstName:(if $loan_relations.title and $loan_relations.title != \"\" then $loan_relations.title + \" \" + $loan_relations.first_name else $loan_relations.first_name end),\n                    lastName:(if $loan_relations.suffix and $loan_relations.suffix != \"\" then $loan_relations.last_name + \" \" + $loan_relations.suffix else $loan_relations.last_name end),\n                    creditScore:( try (.loan_aggregator[] | select(.aggregator_type == \"fico\" and .is_latest == true) | .details.fico.principals[] | select(.SSN == $loan_relations.tin) | .ficoScore | tonumber) //null),\n                    creditScoreDate:(try (.loan_aggregator[] | select(.aggregator_type == \"fico\" and .is_latest == true) | (if .modified then .modified | split(\"T\")[0] else \"\" end) ) // null) \n                },\n            memberOf: ( if ($loan_relations.entity_type == \"sole_proprietor\") then [ \n                {\n                    entityName: (if ($loan_relations.dba_name and $loan_relations.dba_name != \"\") then $loan_relations.dba_name else ( (if $loan_relations.title and $loan_relations.title != \"\" then $loan_relations.title + \" \" + $loan_relations.first_name else $loan_relations.first_name end) + (if ($loan_relations.middle_name and $loan_relations.middle_name != \"\") then \" \" + $loan_relations.middle_name else \"\" end) + \" \" + (if ($loan_relations.suffix and $loan_relations.suffix != \"\") then $loan_relations.last_name + \" \" + $loan_relations.suffix else $loan_relations.last_name end ) ) end ),\n                    jobTitle: \"Proprietor\",\n                    ownershipPercentage: 100,\n                    signer: ($loan_relations.is_signer),\n                    controllingMember: ($loan_relations.is_ben_owner_by_control) \n                } \n            ] else [\n                { \n                    entityName: (if $loan_relations.memberof then $loan_relations.memberof else (if $loan_relations.entity_type == \"sole_proprietor\" then (if ($loan_relations.dba_name and $loan_relations.dba_name != \"\") then $loan_relations.dba_name else ( (if $loan_relations.title and $loan_relations.title != \"\" then $loan_relations.title + \" \" + $loan_relations.first_name else $loan_relations.first_name end) + (if ($loan_relations.middle_name and $loan_relations.middle_name != \"\") then \" \" + $loan_relations.middle_name else \"\" end) + \" \" + (if ($loan_relations.suffix and $loan_relations.suffix != \"\") then $loan_relations.last_name + \" \" + $loan_relations.suffix else $loan_relations.last_name end ) ) end ) else empty end) end),\n                    jobTitle: (\n                        if $loan_relations.position == \"Managing Member\" \n                            then \"Member/Manager\" \n                        else $loan_relations.position\n                        end // null\n                    ),\n                    ownershipPercentage: $loan_relations.ownership_percentage,\n                    signer: ($loan_relations.is_signer),\n                    controllingMember: ($loan_relations.is_ben_owner_by_control) \n                }\n            ] end)\n        }\n    ]\n}",
        "response_body_spec": "{\n apiSuccess:.apiSuccess,\n errors: (if .apiSuccess == false then { errorNum: .errors.errorNum, errorMsg: .errors.errorMsg } else null end),\n responses:(if .apiSuccess == true then { id: .responses.result.id, AccountNumber: .responses.result.detail.logNumber } else null end)\n }",
        "custom_data_mapping": ". as $top | [ \n    { \n        first_time_borrower: ( if .customData | select(\"first_time_borrower\") \n            then { \n                ventures_object:(.customData[] | select(.first_time_borrower) | .first_time_borrower.ventures_object),\n                ventures_field:(.customData[] | select(.first_time_borrower) | .first_time_borrower.ventures_field), \n                value: .details.impact_data | (if .first_time_borrower== \"yes\" \n                    then \"true\" \n                    elif .first_time_borrower == \"no\"\n                        then \"false\"\n                    else empty\n                    end\n                ) \n            } \n        else empty \n        end ) \n    }, \n    { \n        first_time_business_owner:(if .customData | select(\"first_time_business_owner\") \n            then {\n                ventures_object:(.customData[] | select(.first_time_business_owner) | .first_time_business_owner.ventures_object),\n                ventures_field:(.customData[] | select(.first_time_business_owner) | .first_time_business_owner.ventures_field), \n                value: .details.impact_data | (if .first_time_business_owner == \"yes\" \n                    then \"true\" \n                    elif .first_time_business_owner == \"no\"\n                        then \"false\"\n                    else empty\n                    end\n                )\n            } \n        else empty \n        end)\n    }, \n    {\n        low_income_clients: (if .customData | select(\"low_income_clients\") \n            then {\n                ventures_object:(.customData[] | select(.low_income_clients) | .low_income_clients.ventures_object),\n                ventures_field: (.customData[] | select(.low_income_clients) | .low_income_clients.ventures_field), \n                value: .details.impact_data | (if .low_income_clients == \"yes\" \n                    then \"true\" \n                    elif .low_income_clients == \"no\"\n                        then \"false\"\n                    else empty\n                    end\n                )\n            } \n        else empty \n        end )\n    }, \n    {\n        percent_employees_paid_above_living_wage:(if .customData | select(\"percent_employees_paid_above_living_wage\") \n            then {\n                ventures_object:(.customData[] | select(.percent_employees_paid_above_living_wage) | .percent_employees_paid_above_living_wage.ventures_object),\n                ventures_field:(.customData[] | select(.percent_employees_paid_above_living_wage) | .percent_employees_paid_above_living_wage.ventures_field), \n                value: .details.impact_data | ( if .percent_employees_paid_above_living_wage == null \n                    then empty \n                else ( .percent_employees_paid_above_living_wage | split(\"-\") | map(tonumber) | add / length | tostring ) \n                end )\n            } \n        else empty \n        end )\n    }, \n    {\n        living_wage:(if .customData | select(\"living_wage\") then {\n            ventures_object:(.customData[] | select(.living_wage) | .living_wage.ventures_object),\n            ventures_field:(.customData[] | select(.living_wage) | .living_wage.ventures_field), \n            value:  .details.impact_data | ( if .living_wage == null \n                then empty \n                else .living_wage | tostring\n                end\n            )\n        } \n        else empty \n        end)\n    }, \n    {\n        free_reduced_prices:(if .customData | select(\"free_reduced_prices\") \n            then {\n                ventures_object:(.customData[] | select(.free_reduced_prices) | .free_reduced_prices.ventures_object),\n                ventures_field:(.customData[] | select(.free_reduced_prices) | .free_reduced_prices.ventures_field), \n                value: .details.impact_data | (if .free_reduced_prices == \"yes\" \n                    then \"true\" \n                elif .free_reduced_prices == \"no\"\n                    then \"false\"\n                else empty\n                end)\n            } \n        else empty \n        end )\n    }, \n    {\n        projected_percent_of_low_income_clients:(if .customData | select(\"projected_percent_of_low_income_clients\") \n            then {\n                ventures_object:(.customData[] | select(.projected_percent_of_low_income_clients) | .projected_percent_of_low_income_clients.ventures_object),\n                ventures_field:(.customData[] | select(.projected_percent_of_low_income_clients) | .projected_percent_of_low_income_clients.ventures_field), \n                value: .details.impact_data | (if .projected_percent_of_low_income_clients == null\n                    then empty\n                else .projected_percent_of_low_income_clients | split(\"-\") | map(tonumber) | add / length | tostring \n                end )\n            } \n        else empty \n        end )\n    }, \n    {\n        projected_clients_served:(if .customData | select(\"projected_clients_served\")  \n            then {\n                ventures_object:(.customData[] | select(.projected_clients_served) | .projected_clients_served.ventures_object),\n                ventures_field:(.customData[] | select(.projected_clients_served) | .projected_clients_served.ventures_field), \n                value: .details.impact_data | (if .projected_clients_served == null\n                    then empty\n                else .projected_clients_served | tostring \n                end )\n            } \n            else empty \n            end\n        )\n    }, \n    {\n        clients_currently_served:(if .customData | select(\"clients_currently_served\")\n            then {\n                ventures_object:(.customData[] | select(.clients_currently_served) | .clients_currently_served.ventures_object),\n                ventures_field:(.customData[] | select(.clients_currently_served) | .clients_currently_served.ventures_field), \n                value: .details.impact_data | (if .clients_currently_served == null\n                    then empty\n                else .clients_currently_served | tostring\n                end )\n            } \n            else empty \n            end\n        )\n    }, \n    {\n        loan_sale_reviewed:(if .customData | select(\"loan_sale_reviewed\") \n            then {\n                ventures_object:(.customData[] | select(.loan_sale_reviewed) | .loan_sale_reviewed.ventures_object),\n                ventures_field:(.customData[] | select(.loan_sale_reviewed) | .loan_sale_reviewed.ventures_field), \n                value: \"false\"\n            } \n            else empty \n            end\n        )\n    }, \n    {\n        lumos_credit_score:(if .customData | select(\"lumos_credit_score\") \n            then {\n                ventures_object:(.customData[] | select(.lumos_credit_score) | .lumos_credit_score.ventures_object),\n                ventures_field:(.customData[] | select(.lumos_credit_score) | .lumos_credit_score.ventures_field), \n                value: $top.loan_interfaces[] | select(.interface_type == \"lumos\") | .details.lumos_response.results.lumosPrediction.lumos.score | tostring \n            } \n            else empty \n            end\n        )\n    }, \n    {\n        lumos_credit_score_date:(if .customData | select(\"lumos_credit_score_date\") \n            then {\n                ventures_object:(.customData[] | select(.lumos_credit_score_date) | .lumos_credit_score_date.ventures_object),\n                ventures_field:(.customData[] | select(.lumos_credit_score_date) | .lumos_credit_score_date.ventures_field), \n                value: $top.loan_interfaces[] | select(.interface_type == \"lumos\") | .details.lumos_response.metadata.applicationRunDate | split(\"T\")[0] \n            } \n            else empty \n            end\n        )\n    }, \n    {\n        lumos_expected_loss:(if .customData | select(\"lumos_expected_loss\") \n            then {\n                ventures_object:(.customData[] | select(.lumos_expected_loss) | .lumos_expected_loss.ventures_object),\n                ventures_field:(.customData[] | select(.lumos_expected_loss) | .lumos_expected_loss.ventures_field), \n                value: $top.loan_interfaces[] | select(.interface_type == \"lumos\") | .details.lumos_response.results.lumosPrediction.lumos.expectedLoss | sub(\"%\"; \"\") \n            } \n            else empty \n            end\n        )\n    } \n]",
        "request_body_spec_config": "{\n \"purposeType\": {\n \"Purchase Equipment or Vehicles\": \"Equipment\" ,\"Working Capital\": \"Working Capital\"},\"useOfProceedType\":{ \"Purchase Land only\": \"Purchase Of Land\", \"Purchase Land and improvements\": \"Purchase Land & Building\", \"Construct a Building\": \"Construct a Building\", \"Purchase Equipment\": \"Equipment\", \"SBA Guaranty Fee\": \"Soft Cost (Packaging and closing cost)\", \"Purchase Furniture and Fixtures\": \"Fixtures\", \"Other\": \"Other Cost\", \"Add an Addition to an Existing Building\": \"Building Addition\", \"Purchase Improvements only\": \"Purchase Improvement\", \"Make Renovations to an Existing Building\": \"Building Renovation\", \"Leasehold Improvements\": \"Building Leasehold Improvements\", \"Pay Notes Payable - not Same Institution Debt\": \"Pay Notes Payable - NOT Same Institution Debt\", \"Pay Notes Payable - Same Institution Debt\": \"Pay Notes Payable - Same Institution Debt\", \"Pay Off Interim Construction Loan\": \"Pay Off Interim Construction Loan\", \"Pay Off Lender's Interim Loan\": \"Pay Off Lender's Interim Loan\", \"Purchase Inventory\": \"Purchase Inventory\", \"Pay Trade or Accounts Payable\": \"Pay Trade or Accounts Payable\", \"Purchase Business - Stock Purchase\": \"Purchase Business (Change of Ownership)\", \"Purchase Business - Asset Purchase\": \"Purchase Business (Change of Ownership)\", \"Refinance SBA Loan - not Same Institution Debt\": \"Refinance SBA Loan – NOT Same Institution Debt\", \"Working Capital\": \"Working Capital\", \"Refinance SBA Loan - Same Institution Debt\": \"Refinance SBA Loan – Same Institution Debt\" },\"collateralType\":{ \"Equipment\": \"Equipment\", \"machinery_and_equipment\": \"Equipment\", \"commercial_real_estate\":\"Commercial Real Estate\", \"Motor Vehicle\": \"Automobile\", \"vehicles\": \"Automobile\", \"life_insurance\":\"Life Insurance\", \"All Assets\": \"Business Assets\", \"inventory_accounts_receivable\":\"Inventory\", \"other\":\"Other\", \"cash_and_equivalents\":\"Other\", \"furniture_fixtures_equipment\":\"Furniture and Fixtures\", \"assignment_of_leases\":\"Assignment of Leases & Rents\", \"land\":\"Ground Lease (Land Only No Improvements)\" }\n}",
        "response_body_spec_config": "{}"
    },
    "ci-ventures-create_payments_account": {
        "validation_spec": "{}",
        "request_body_spec": "{\n    amountFinanced: ((.approved_amount) // null),\n    firstPaymentDate: ((.loan_approval.approved_first_payment_date) // null),\n    fundingDate: ((.funding_details.funding_date) // null),\n    initialDisbursement: (((.loan_approval.approved_amount // 0) - (.disbursements.remaining_amount // 0)) // null),\n    interestRatePercent: ((.loan_approval.approved_rate) // null),\n    loanId: ((if .loan_number then .loan_number | tonumber else null end) // null),\n    maturityDate: ((.maturity_date) // null),\n    rateType: (.pricing_details[] | select(.term_position == \"term_1\") | (.rate_type) // null),\n    adjustmentPeriod: (null),\n    balloonPaymentAmount: ( if( .product.product_code == \"SB_TL\" and(\n    .pricing_details | map( select(\n    (.repayment_type == \"principal_and_interest\")\n    and (.amortization_in_months > .term_in_months))) |  length > 0 ) ) \n    then (\n        .loan_interfaces[]\n        | select(\n            .interface_type == \"sherman\"\n            and .is_latest == true\n            and .details.outLOAN_BUILDER?\n            and .details.outLOAN_BUILDER.AmTable?\n            and .details.outLOAN_BUILDER.AmTable.AmLine?\n    ) | (.details.outLOAN_BUILDER.AmTable.AmLine | max_by(.Idx) | .Pmt | tonumber)\n    ) else null end ),\n    finalPayment: (null),\n    firstPAndIPaymentAmount: (if(.product.product_code == \"SB_TL\" or .product.product_code == \"7A_TL\")  then ( .loan_interfaces[] | select(\n        .interface_type == \"sherman\"\n        and .is_latest == true\n        and .details.outLOAN_BUILDER.AmTable?\n        and .details.outLOAN_BUILDER.AmTable.AmLine?\n    ) | .details.outLOAN_BUILDER.AmTable.AmLine[] | select(.Idx == \"1\") | .Pmt | tonumber)\n    else null end\n    ),\n    firstPAndIPaymentDate: (.loan_approval.approved_first_payment_date // null),\n    fixedPrincipalAmount: (null),\n    guarantyPercent: ((.sba_express_details.sba_guaranty_percent) // null),\n    indexBaseRatePercent: (.pricing_details[] | select(.term_position == \"term_1\") | .prime_rate // null) ,\n    interestBasis: ($accrualMapping[ .accrual_method | tostring] // null),\n    interestRateCeilingPercent: ((.max_rate) // (.product.max_rate)),\n    interestRateFloorPercent: ((.min_rate) // (.product.min_rate)),\n    interestRateSpreadPercent: ((.differential_rate) // null),\n    interestRoundingMethod: (null),\n    interestRoundingPerDiem: (null),\n    lineOfCredit: (if .product.product_type.name | ascii_downcase == \"line of credit\" then true else false end),\n    loanIdentifier: ((.core_integration_response.create_loan.response.responses.AccountNumber) // null | tostring),\n    nextInterestAdjustmentDate: (null),\n    nextReamortizationDate: (null),\n    paymentAmount: ((.loan_interfaces[]? | select(.interface_type == \"sherman\" and .is_latest == true) | .details.outLOAN_BUILDER.AmTable.AmLine[]? | select(.Idx == \"1\" ) | .Pmt | tonumber ) //0 ),\n    paymentFrequency: (.pricing_details[] | select(.term_position == \"term_1\") | .frequency // null),\n    paymentLateFeePercent: (null),\n    paymentType: (.pricing_details[] | select(.term_position == \"term_1\") | $repaymentTypeMapping[.repayment_type] // null ),\n    rateIndex: ((.pricing_details[] | select(.term_position == \"term_1\" and .rate_index!=null and .index_period_type!=null) | \n        if (.index_period_type <= 5 and .rate_index == \"US Treasury Securities Rate\") then  (\"Treasury5Year\")\n        elif (.index_period_type <= 5 and .rate_index == \"Treasury Constant Maturities\") then (\"CMT5Year\")\n        else $rateIndexMapping[.rate_index] end // null) // null),\n    reamortizationPeriod: (null),\n    revolvingTermEndDate: (.revolving_term_end_date // null),\n    sba1502Status: (null),\n}",
        "response_body_spec": "{\n    apiSuccess: (if .responses | has(\"succeeded\") then .responses | .succeeded else false end),\n    errors: ((.responses | .messages) // null),\n    responses: (if .responses | .succeeded then \n        {\n            payments_account_id: .responses.result.id\n        } else null end\n    )\n}", 
        "request_body_spec_config": "{    \"accrualMapping\": {\n        \"310\": \"Actual360\",\n        \"320\": \"Actual365\",\n        \"201\": \"Even30DayMonths360\",\n        \"311\": \"Even30DayMonths365\"\n    },\n    \"repaymentTypeMapping\": {\n        \"principal_only\": \"FixedPrincipal\",\n        \"principal_and_interest\": \"PrincipalAndInterest\",\n        \"interest_only\": \"InterestOnly\"\n    },\n    \"rateIndexMapping\": {\n        \"Wall Street Journal Prime\": \"WallStreetJournalPrime\",\n        \"Federal Home Loan Banks\": \"FederalHomeLoanBankBoard\",\n        \"US Treasury Securities Rate\": \"Treasury10Year\",\n        \"Treasury Constant Maturities\": \"CMT10Year\",\n        \"SOFR\": \"Other\"\n    }\n}", 
        "response_body_spec_config": "{}"
    },
    "ci-ventures-documenttype_data": {
        "request_body": "50000", 
        "validation_spec": "{}", 
        "response_body_spec": "{\n apiSuccess: .responses.succeeded,\n errors: .errors,\n responses: [(if .responses.succeeded then .responses.result[] | {\n documentTypeGuid:.id,\n documentTypeName:.name,\n uuid:.uuid,\n applicationName:\"Loan\"} else null end)] }", 
        "document_type_mapping": {"Bylaws": {"applicationName": "Loan", "documentTypeName": "CORPORATION DOCUMENTS"}, "UCC Search": {"applicationName": "Loan", "documentTypeName": "UCCS FOR PROJECT PROPERTY"}, "Credit Memo": {"applicationName": "Loan", "documentTypeName": "CREDIT MEMORANDUM"}, "Fico Report": {"applicationName": "Loan", "documentTypeName": "ALL CREDIT REPORTS-EXPLANATIONS"}, "Tax Archive": {"applicationName": "Loan", "documentTypeName": "APP MISCELLANEOUS"}, "US Passport": {"applicationName": "Loan", "documentTypeName": "SBA 912 NAME AFFDVT RESUME CIP"}, "Spreading Data": {"applicationName": "Loan", "documentTypeName": "CREDIT MEMORANDUM"}, "Stock Transfer": {"applicationName": "Loan", "documentTypeName": "CORPORATION DOCUMENTS"}, "Lease Agreement": {"applicationName": "Loan", "documentTypeName": "CURRENT-PROPOSED LEASE"}, "TITLE INSURANCE": {"applicationName": "Loan", "documentTypeName": "TITLE INSURANCE"}, "Appraisal Report": {"applicationName": "Loan", "documentTypeName": "APPRAISAL FOR PROPERTY-CHECKLIST SBA APP"}, "Board Resolution": {"applicationName": "Loan", "documentTypeName": "RESOLUTION OF BOARD OF DIRECTORS"}, "Business License": {"applicationName": "Loan", "documentTypeName": "BUSINESS PROFESSIONAL LICENSES"}, "Driver's License": {"applicationName": "Loan", "documentTypeName": "SBA 912 NAME AFFDVT RESUME CIP"}, "Spreading Report": {"applicationName": "Loan", "documentTypeName": "APP MISCELLANEOUS"}, "Commitment Letter": {"applicationName": "Loan", "documentTypeName": "LENDER COMMITMENT LETTER LENDER CREDIT MEMO"}, "Management Resume": {"applicationName": "Loan", "documentTypeName": "APP MISCELLANEOUS"}, "Power Of Attorney": {"applicationName": "Loan", "documentTypeName": "OTHER-MISC CLOSING"}, "UCC Search Report": {"applicationName": "Loan", "documentTypeName": "SEARCH TO REFLECT"}, "Approval Worksheet": {"applicationName": "Loan", "documentTypeName": "LENDER COMMITMENT LETTER LENDER CREDIT MEMO"}, "Purchase Agreement": {"applicationName": "Loan", "documentTypeName": "PURCHASE AGRMNT-ESCROW INST-LTR TO ESCROW"}, "Stock Certificates": {"applicationName": "Loan", "documentTypeName": "CORPORATION DOCUMENTS"}, "Tax Spreading Data": {"applicationName": "Loan", "documentTypeName": "CREDIT MEMORANDUM"}, "UCC Filing Preview": {"applicationName": "Loan", "documentTypeName": "UCCS FOR PROJECT PROPERTY"}, "Closing document(s)": {"applicationName": "Loan", "documentTypeName": "BULK UPLOAD"}, "Franchise Agreement": {"applicationName": "Loan", "documentTypeName": "FRANCHISE AGRMNT FTC DISCLOSURE"}, "Operating Agreement": {"applicationName": "Loan", "documentTypeName": "LLC ARTICLES AND OPERATING AGREEMENT"}, "Classified Documents": {"applicationName": "Loan", "documentTypeName": "OTHER-MISC CLOSING"}, "Corporate Resolution": {"applicationName": "Loan", "documentTypeName": "RESOLUTION OF BOARD OF DIRECTORS"}, "Credit Memo Document": {"applicationName": "Loan", "documentTypeName": "CREDIT MEMORANDUM"}, "Invoice/Bill of Sale": {"applicationName": "Loan", "documentTypeName": "LIST OF EQUIP TO BE ACQUIRED WITH PROCEEDS"}, "Management Agreement": {"applicationName": "Loan", "documentTypeName": "CORPORATION DOCUMENTS"}, "Partnership Agreement": {"applicationName": "Loan", "documentTypeName": "PARTNERSHIP AGREEMENT"}, "CAIVRS Search Document": {"applicationName": "Loan", "documentTypeName": "CAIVRS"}, "Preclosing document(s)": {"applicationName": "Loan", "documentTypeName": "OTHER-MISC CLOSING"}, "Unclassified Documents": {"applicationName": "Loan", "documentTypeName": "APP MISCELLANEOUS"}, "Complete Trust Document": {"applicationName": "Loan", "documentTypeName": "TRUST AGREEMENT"}, "Customer Correspondence": {"applicationName": "Loan", "documentTypeName": "APP MISCELLANEOUS"}, "Loan Exception Document": {"applicationName": "Loan", "documentTypeName": "APP MISCELLANEOUS"}, "SAM.gov Search Document": {"applicationName": "Loan", "documentTypeName": "CAIVRS"}, "Sole Prop Certification": {"applicationName": "Loan", "documentTypeName": "SOLEPROP-FBNS"}, "Etran Loan Auth Document": {"applicationName": "Loan", "documentTypeName": "LOAN AUTHORIZATION 327 ACTION LETTERS"}, "Certificate of Trade Name": {"applicationName": "Loan", "documentTypeName": "SOLEPROP-FBNS"}, "Counter Offer document(s)": {"applicationName": "Loan", "documentTypeName": "LENDER COMMITMENT LETTER LENDER CREDIT MEMO"}, "Proof of Business Address": {"applicationName": "Loan", "documentTypeName": "CDC APPLICATION"}, "Proof of Personal Address": {"applicationName": "Loan", "documentTypeName": "CDC APPLICATION"}, "Property Insurance Policy": {"applicationName": "Loan", "documentTypeName": "HAZARD INSURANCE"}, "Closing signed document(s)": {"applicationName": "Loan", "documentTypeName": "OTHER-MISC CLOSING"}, "Flood Determination Report": {"applicationName": "Loan", "documentTypeName": "FLOOD INSURANCE-FEMA FORM"}, "Loan amortization schedule": {"applicationName": "Loan", "documentTypeName": "AMORTIZATION AND PREPAY SCHEDULES"}, "Certificate of Organization": {"applicationName": "Loan", "documentTypeName": "CERTIFICATE OF GOOD STANDING"}, "Closing summary document(s)": {"applicationName": "Loan", "documentTypeName": "OTHER-MISC CLOSING"}, "Fictitious Name Certificate": {"applicationName": "Loan", "documentTypeName": "SOLEPROP-FBNS"}, "Insurance Declarations page": {"applicationName": "Loan", "documentTypeName": "HAZARD INSURANCE"}, "Auto/Business Auto Insurance": {"applicationName": "Loan", "documentTypeName": "HAZARD INSURANCE"}, "Personal Financial Statement": {"applicationName": "Loan", "documentTypeName": "PERSONAL FINANCIAL STATEMENT"}, "Signed 8821 Consent Document": {"applicationName": "Loan", "documentTypeName": "TAX TRANSCRIPTS-BUSINESS"}, "Application signed document(s)": {"applicationName": "Loan", "documentTypeName": "CDC APPLICATION"}, "Current Business Debt Schedule": {"applicationName": "Loan", "documentTypeName": "BUSINESS DEBT SCHEDULE"}, "US Armed Forces or Military ID": {"applicationName": "Loan", "documentTypeName": "SBA 912 NAME AFFDVT RESUME CIP"}, "Unsigned 8821 Consent Document": {"applicationName": "Loan", "documentTypeName": "APP MISCELLANEOUS"}, "Application summary document(s)": {"applicationName": "Loan", "documentTypeName": "APP MISCELLANEOUS"}, "Primary Identification Document": {"applicationName": "Loan", "documentTypeName": "SBA 912 NAME AFFDVT RESUME CIP"}, "State or County DBA Certificate": {"applicationName": "Loan", "documentTypeName": "SOLEPROP-FBNS"}, "Federal Tax Return (most recent)": {"applicationName": "Loan", "documentTypeName": "PERSONAL FEDERAL INCOME TAX RETURN"}, "General Liability (GL) Insurance": {"applicationName": "Loan", "documentTypeName": "OTHER INSURANCE"}, "Approval with conditions document": {"applicationName": "Loan", "documentTypeName": "CREDIT MEMORANDUM"}, "DBA / Fictitious Name Certificate": {"applicationName": "Loan", "documentTypeName": "APP MISCELLANEOUS"}, "Secondary Identification Document": {"applicationName": "Loan", "documentTypeName": "SBA 912 NAME AFFDVT RESUME CIP"}, "Business Tax Return for prior year": {"applicationName": "Loan", "documentTypeName": "BUSINESS FEDERAL TAX RETURN-YEAR 2"}, "Certificate of Limited Partnership": {"applicationName": "Loan", "documentTypeName": "LLPAGREEMENT"}, "Personal tax return for prior year": {"applicationName": "Loan", "documentTypeName": "PERSONAL FEDERAL INCOME TAX RETURN"}, "Property Insurance Declarations Page": {"applicationName": "Loan", "documentTypeName": "HAZARD INSURANCE"}, "State or Federal Government Issued ID": {"applicationName": "Loan", "documentTypeName": "SBA 912 NAME AFFDVT RESUME CIP"}, "Business Tax Returns for 2 years' prior": {"applicationName": "Loan", "documentTypeName": "BUSINESS FEDERAL TAX RETURN-YEAR 3"}, "Hazard insurance (could be auto policy)": {"applicationName": "Loan", "documentTypeName": "HAZARD INSURANCE"}, "Limited Liability Partnership Agreement": {"applicationName": "Loan", "documentTypeName": "LLPAGREEMENT"}, "Pre Closing Document signed document(s)": {"applicationName": "Loan", "documentTypeName": "OTHER-MISC CLOSING"}, "Schedule K-1 on Guarantor (most recent)": {"applicationName": "Loan", "documentTypeName": "PERSONAL FEDERAL INCOME TAX RETURN"}, "US Permanent Resident Card (Green Card)": {"applicationName": "Loan", "documentTypeName": "USCIS FORMS G-845 ALIEN REG CARD"}, "Business Tax Return for most recent year": {"applicationName": "Loan", "documentTypeName": "BUSINESS FEDERAL TAX RETURN-YEAR 1"}, "Personal tax return for most recent year": {"applicationName": "Loan", "documentTypeName": "PERSONAL FEDERAL INCOME TAX RETURN"}, "Pre Closing Document summary document(s)": {"applicationName": "Loan", "documentTypeName": "OTHER-MISC CLOSING"}, "Officer Roster or Organization Resolution": {"applicationName": "Loan", "documentTypeName": "CORPORATION DOCUMENTS"}, "Hazard insurance/Business Personal Property": {"applicationName": "Loan", "documentTypeName": "HAZARD INSURANCE"}, "Assumed Name Certificate or Business License": {"applicationName": "Loan", "documentTypeName": "BUSINESS-PROFESSIONAL LICENSES"}, "Hazard insurance (could be Marine Insurance)": {"applicationName": "Loan", "documentTypeName": "HAZARD INSURANCE"}, "Articles of Incorporation (dated and certified)": {"applicationName": "Loan", "documentTypeName": "CORPORATION DOCUMENTS"}, "Manufacture Statement of Origin if new purchase": {"applicationName": "Loan", "documentTypeName": "INJECTION-CERT FINAL CLSNG STMNT AND CERT"}, "Signed Etran Loan Authorization (T&C) Documents": {"applicationName": "Loan", "documentTypeName": "LOAN AUTHORIZATION 327 ACTION LETTERS"}, "Copy of most recent Schedule K-1 on Guarantor(s)": {"applicationName": "Loan", "documentTypeName": "PERSONAL FEDERAL INCOME TAX RETURN"}, "Certificate of Organization (dated and certified)": {"applicationName": "Loan", "documentTypeName": "LLC ARTICLES AND OPERATING AGREEMENT"}, "Articles of Association with at least two signatures": {"applicationName": "Loan", "documentTypeName": "CORPORATION DOCUMENTS"}, "Business's most recent quarter-to-date Balance Sheet": {"applicationName": "Loan", "documentTypeName": "BUSINESS INTERIM FINANCIAL STATEMENT"}, "Personal Financial Statement (dated within 120 days)": {"applicationName": "Loan", "documentTypeName": "PERSONAL FEDERAL INCOME TAX RETURN"}, "Business's most recent quarter-to-date Income Statement": {"applicationName": "Loan", "documentTypeName": "BUSINESS INTERIM FINANCIAL STATEMENT"}, "Operating Agreement (if ownership percentage is stated)": {"applicationName": "Loan", "documentTypeName": "LLC ARTICLES AND OPERATING AGREEMENT"}, "Most recent filed federal tax returns (Two years preferred)": {"applicationName": "Loan", "documentTypeName": "BUSINESS FEDERAL TAX RETURN-YEAR 1"}, "Primary ID Document - Drivers License or State ID/Passport/Green Card": {"applicationName": "Loan", "documentTypeName": "APP MISCELLANEOUS"}, "Meeting minutes appointing signers and signed by Association Secretary": {"applicationName": "Loan", "documentTypeName": "CORPORATION DOCUMENTS"}}, "response_body_spec_config": "{}"
    },
    "ci-ventures-search_accounts": {
        "validation_spec": "{}",
        "request_body_spec": ".",
        "response_body_spec": "{\n  apiSuccess: (if .responses|has(\"succeeded\") then .responses|.succeeded else false end), \n  errors: .responses|.messages,\n  responses: (\n    if .responses|.succeeded and .result then \n        if (.responses.result | type == \"array\") then \n            [.responses.result[]]\n        elif (.responses.result|type == \"object\") then \n            [.responses.result]\n        else null end\n  else null end)\n}",
        "request_body_spec_config": "{}",
        "response_body_spec_config": "{}"
    },
    "ci-ventures-documenttype_data": {
    "request_body": "50000",
    "validation_spec": "{}",
    "response_body_spec": "{\n   apiSuccess: .responses.succeeded,\n   errors: .errors,\n   responses: [(if .responses.succeeded then .responses.result[] | {\n documentTypeGuid:.id,\n documentTypeName:.name,\n uuid:.uuid,\n applicationName:\"Loan\"}  else  null  end)] }",
    "document_type_mapping": {
        "W2": {
        "applicationName": "Loan",
        "documentTypeName": "IRS W-2"
        },
        "LOI": {
        "applicationName": "Loan",
        "documentTypeName": "Letter of Intent"
        },
        "Visa": {
        "applicationName": "Loan",
        "documentTypeName": "Visa"
        },
        "W-9s": {
        "applicationName": "Loan",
        "documentTypeName": "W-9"
        },
        "Title": {
        "applicationName": "Loan",
        "documentTypeName": "Title"
        },
        "Bylaws": {
        "applicationName": "Loan",
        "documentTypeName": "Bylaws"
        },
        "Others": {
        "applicationName": "Loan",
        "documentTypeName": "Other Supporting Application Documents"
        },
        "Survey": {
        "applicationName": "Loan",
        "documentTypeName": "Survey"
        },
        "By-Laws": {
        "applicationName": "Loan",
        "documentTypeName": "Bylaws"
        },
        "Invoice": {
        "applicationName": "Loan",
        "documentTypeName": "Invoice"
        },
        "Passport": {
        "applicationName": "Loan",
        "documentTypeName": "US Passport ID"
        },
        "Appraisal": {
        "applicationName": "Loan",
        "documentTypeName": "Appraisal"
        },
        "Asset List": {
        "applicationName": "Loan",
        "documentTypeName": "Asset List"
        },
        "Term Sheet": {
        "applicationName": "Loan",
        "documentTypeName": "Term Sheet"
        },
        "Credit Memo": {
        "applicationName": "Loan",
        "documentTypeName": "Credit Memorandum"
        },
        "RSRA Report": {
        "applicationName": "Loan",
        "documentTypeName": "RSRA Report"
        },
        "Seller Note": {
        "applicationName": "Loan",
        "documentTypeName": "Seller Note"
        },
        "US Passport": {
        "applicationName": "Loan",
        "documentTypeName": "US Passport ID"
        },
        "Bill of Sale": {
        "applicationName": "Loan",
        "documentTypeName": "Bill of Sale"
        },
        "IRS Form 941": {
        "applicationName": "Loan",
        "documentTypeName": "IRS Form 941"
        },
        "Schedule K-1": {
        "applicationName": "Loan",
        "documentTypeName": "Schedule K-1"
        },
        "Business Plan": {
        "applicationName": "Loan",
        "documentTypeName": "Business Plan"
        },
        "Debt Schedule": {
        "applicationName": "Loan",
        "documentTypeName": "Debt Schedule"
        },
        "Deed of Trust": {
        "applicationName": "Loan",
        "documentTypeName": "Deed Trust"
        },
        "Due Diligence": {
        "applicationName": "Loan",
        "documentTypeName": "Due Diligence"
        },
        "Survey report": {
        "applicationName": "Loan",
        "documentTypeName": "Survey"
        },
        "Vehicle Title": {
        "applicationName": "Loan",
        "documentTypeName": "Vehicle Title"
        },
        "Veteran-DD214": {
        "applicationName": "Loan",
        "documentTypeName": "Veteran-DD214"
        },
        "Auto Insurance": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Automobile "
        },
        "Equipment List": {
        "applicationName": "Loan",
        "documentTypeName": "Equipment List"
        },
        "Gift Affidavit": {
        "applicationName": "Loan",
        "documentTypeName": "Gift Affidavit"
        },
        "Name Affidavit": {
        "applicationName": "Loan",
        "documentTypeName": "Name Affidavit"
        },
        "Officer Roster": {
        "applicationName": "Loan",
        "documentTypeName": "Officer Roster"
        },
        "Spreading Data": {
        "applicationName": "Loan",
        "documentTypeName": "Spreading Data"
        },
        "Wind Insurance": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Wind"
        },
        "Asset Agreement": {
        "applicationName": "Loan",
        "documentTypeName": "Asset Agreement"
        },
        "Building Permit": {
        "applicationName": "Loan",
        "documentTypeName": "Building Permit"
        },
        "Drivers License": {
        "applicationName": "Loan",
        "documentTypeName": "State Issued ID/Drivers License"
        },
        "Equipment Quote": {
        "applicationName": "Loan",
        "documentTypeName": "Equipment Quote"
        },
        "Flood Insurance": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Flood"
        },
        "Lease Agreement": {
        "applicationName": "Loan",
        "documentTypeName": "Lease"
        },
        "Other Documents": {
        "applicationName": "Loan",
        "documentTypeName": "Other Supporting Application Documents"
        },
        "Payment History": {
        "applicationName": "Loan",
        "documentTypeName": "Payment History"
        },
        "Title Insurance": {
        "applicationName": "Loan",
        "documentTypeName": "Title Insurance"
        },
        "Trust Agreement": {
        "applicationName": "Loan",
        "documentTypeName": "Trust Agreement"
        },
        "Veteran-ID Card": {
        "applicationName": "Loan",
        "documentTypeName": "Military ID"
        },
        "Appraisal Report": {
        "applicationName": "Loan",
        "documentTypeName": "Appraisal"
        },
        "Archive Document": {
        "applicationName": "Loan",
        "documentTypeName": "Archive Document"
        },
        "Board Resolution": {
        "applicationName": "Loan",
        "documentTypeName": "Board Resolution"
        },
        "Building Permits": {
        "applicationName": "Loan",
        "documentTypeName": "Building Permit"
        },
        "Business License": {
        "applicationName": "Loan",
        "documentTypeName": "Business Licenses"
        },
        "Core Screenshots": {
        "applicationName": "Loan",
        "documentTypeName": "Core Screenshots"
        },
        "Corporate Bylaws": {
        "applicationName": "Loan",
        "documentTypeName": "Corporate Bylaws"
        },
        "DBA Registration": {
        "applicationName": "Loan",
        "documentTypeName": "DBA Registration"
        },
        "Driver's License": {
        "applicationName": "Loan",
        "documentTypeName": "State Issued ID/Drivers License"
        },
        "Equity Injection": {
        "applicationName": "Loan",
        "documentTypeName": "Equity Injection Documentation"
        },
        "Expenses Prepaid": {
        "applicationName": "Loan",
        "documentTypeName": "Prepaid Expenses"
        },
        "Hazard Insurance": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Hazard"
        },
        "Installment Plan": {
        "applicationName": "Loan",
        "documentTypeName": "Installment Plan"
        },
        "Marine Insurance": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Inland Marine"
        },
        "Payoff Statement": {
        "applicationName": "Loan",
        "documentTypeName": "Loan Payoff Statement"
        },
        "Title Commitment": {
        "applicationName": "Loan",
        "documentTypeName": "Title Commitment"
        },
        "USCIS Form G-845": {
        "applicationName": "Loan",
        "documentTypeName": "USCIS Verification"
        },
        "Valuation Report": {
        "applicationName": "Loan",
        "documentTypeName": "Business Valuation"
        },
        "Current Rent Roll": {
        "applicationName": "Loan",
        "documentTypeName": "Rent Roll"
        },
        "Landlord's Waiver": {
        "applicationName": "Loan",
        "documentTypeName": "Landlord's Waiver"
        },
        "Management Resume": {
        "applicationName": "Loan",
        "documentTypeName": "Resume"
        },
        "Original Approval": {
        "applicationName": "Loan",
        "documentTypeName": "Original Approval"
        },
        "Owner Certificate": {
        "applicationName": "Loan",
        "documentTypeName": "Owner Certificate"
        },
        "Power Of Attorney": {
        "applicationName": "Loan",
        "documentTypeName": "Power of Attorney"
        },
        "Required Document": {
        "applicationName": "Loan",
        "documentTypeName": "Miscellaneous Documents"
        },
        "Vehicle Insurance": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Automobile "
        },
        "Wire Instructions": {
        "applicationName": "Loan",
        "documentTypeName": "Wire Instructions"
        },
        "Borrower Pro Forma": {
        "applicationName": "Loan",
        "documentTypeName": "Borrower Pro Forma"
        },
        "Construction Quote": {
        "applicationName": "Loan",
        "documentTypeName": "Construction Bids"
        },
        "Purchase Agreement": {
        "applicationName": "Loan",
        "documentTypeName": "Purchase Agreement"
        },
        "Stock Certificates": {
        "applicationName": "Loan",
        "documentTypeName": "Stock Certificates"
        },
        "Annual STARR Report": {
        "applicationName": "Loan",
        "documentTypeName": "Annual STARR Report"
        },
        "Construction Budget": {
        "applicationName": "Loan",
        "documentTypeName": "Construction Budget"
        },
        "Contractors License": {
        "applicationName": "Loan",
        "documentTypeName": "Contractors License"
        },
        "Equity Confirmation": {
        "applicationName": "Loan",
        "documentTypeName": "Equity Confirmation"
        },
        "Franchise Agreement": {
        "applicationName": "Loan",
        "documentTypeName": "Franchise Documents"
        },
        "History of Business": {
        "applicationName": "Loan",
        "documentTypeName": "History of Business"
        },
        "IRS Tax Transcripts": {
        "applicationName": "Loan",
        "documentTypeName": "IRS Tax Transcripts"
        },
        "One Month Statement": {
        "applicationName": "Loan",
        "documentTypeName": "Statement"
        },
        "Operating Agreement": {
        "applicationName": "Loan",
        "documentTypeName": "Operating Agreement"
        },
        "Personal Tax Return": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Personal"
        },
        "State or Federal ID": {
        "applicationName": "Loan",
        "documentTypeName": "State Issued ID/Drivers License"
        },
        "Title Search Report": {
        "applicationName": "Loan",
        "documentTypeName": "Title Search Report"
        },
        "Verification of EIN": {
        "applicationName": "Loan",
        "documentTypeName": "Verification of EIN"
        },
        "Classified Documents": {
        "applicationName": "Loan",
        "documentTypeName": "Classified Documents"
        },
        "Corporate Resolution": {
        "applicationName": "Loan",
        "documentTypeName": "Corporate Resolution"
        },
        "Credit Bureau Report": {
        "applicationName": "Loan",
        "documentTypeName": "Credit Report - Personal"
        },
        "Credit Memo Document": {
        "applicationName": "Loan",
        "documentTypeName": "Credit Memorandum"
        },
        "Financial Statements": {
        "applicationName": "Loan",
        "documentTypeName": "Financial Statements"
        },
        "Franchise Agreement ": {
        "applicationName": "Loan",
        "documentTypeName": "Franchise Documents"
        },
        "Invoice/Bill of Sale": {
        "applicationName": "Loan",
        "documentTypeName": "Bill of Sale"
        },
        "Licenses and Permits": {
        "applicationName": "Loan",
        "documentTypeName": "Licenses/Permits"
        },
        "Management Agreement": {
        "applicationName": "Loan",
        "documentTypeName": "Management Agreement"
        },
        "Occupational License": {
        "applicationName": "Loan",
        "documentTypeName": "Occupational License"
        },
        "Organizational Chart": {
        "applicationName": "Loan",
        "documentTypeName": "Organizational Chart"
        },
        "Plan and Cost Review": {
        "applicationName": "Loan",
        "documentTypeName": "Plan and Cost Review"
        },
        "Proof of Tax Payment": {
        "applicationName": "Loan",
        "documentTypeName": "Proof of Tax Payment"
        },
        "Relationship Summary": {
        "applicationName": "Loan",
        "documentTypeName": "Relationship Summary"
        },
        "Social Security Card": {
        "applicationName": "Loan",
        "documentTypeName": "Social Security Card"
        },
        "Sources & Uses Chart": {
        "applicationName": "Loan",
        "documentTypeName": "Sources & Uses Chart"
        },
        "Board Meeting Minutes": {
        "applicationName": "Loan",
        "documentTypeName": "Board Meeting Minutes"
        },
        "Business Voided Check": {
        "applicationName": "Loan",
        "documentTypeName": "ACH Form With Voided Check"
        },
        "Construction Contract": {
        "applicationName": "Loan",
        "documentTypeName": "Construction Contract"
        },
        "Credit Card Statement": {
        "applicationName": "Loan",
        "documentTypeName": "Credit Card Statement"
        },
        "Current Profit & Loss": {
        "applicationName": "Loan",
        "documentTypeName": "Profit & Loss"
        },
        "Interim Balance Sheet": {
        "applicationName": "Loan",
        "documentTypeName": "Balance Sheet"
        },
        "Life Insurance Policy": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Life"
        },
        "Malpractice Insurance": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Malpractice"
        },
        "Non-Compete Agreement": {
        "applicationName": "Loan",
        "documentTypeName": "Non-Compete Agreement"
        },
        "Partnership Agreement": {
        "applicationName": "Loan",
        "documentTypeName": "Partnership Agreement"
        },
        "Business Debt Schedule": {
        "applicationName": "Loan",
        "documentTypeName": "Debt Schedule"
        },
        "CAIVRS Search Document": {
        "applicationName": "Loan",
        "documentTypeName": "CAIVRS & SAM"
        },
        "Deposit Decline Letter": {
        "applicationName": "Loan",
        "documentTypeName": "Deposit Decline Letter"
        },
        "Insurance Certificates": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Other"
        },
        "Invoice / Bill of Sale": {
        "applicationName": "Loan",
        "documentTypeName": "Bill of Sale"
        },
        "Projection Assumptions": {
        "applicationName": "Loan",
        "documentTypeName": "Business Projections with Assumptions"
        },
        "SBA Addendum Form 2462": {
        "applicationName": "Loan",
        "documentTypeName": "SBA Addendum Form 2462"
        },
        "Site Inspection Report": {
        "applicationName": "Loan",
        "documentTypeName": "Site Visit"
        },
        "Tax Lien Documentation": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Lien Documentation"
        },
        "Unclassified Documents": {
        "applicationName": "Loan",
        "documentTypeName": "Unclassified Documents"
        },
        "Veteran-Spouse ID Card": {
        "applicationName": "Loan",
        "documentTypeName": "Military ID"
        },
        "Year End Balance Sheet": {
        "applicationName": "Loan",
        "documentTypeName": "Balance Sheet"
        },
        "Year End Profit & Loss": {
        "applicationName": "Loan",
        "documentTypeName": "Profit & Loss"
        },
        "Bank Account Statements": {
        "applicationName": "Loan",
        "documentTypeName": "Bank Statements - Business/Personal"
        },
        "Builders Risk Insurance": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Builders Risk"
        },
        "Complete Trust Document": {
        "applicationName": "Loan",
        "documentTypeName": "Complete Trust Document"
        },
        "Copies Of Paid Invoices": {
        "applicationName": "Loan",
        "documentTypeName": "Copy of Paid Invoices"
        },
        "Landlord Consent/Waiver": {
        "applicationName": "Loan",
        "documentTypeName": "Landlord Consent/Waiver"
        },
        "Organization Resolution": {
        "applicationName": "Loan",
        "documentTypeName": "Organization Resolution"
        },
        "SAM.gov Search Document": {
        "applicationName": "Loan",
        "documentTypeName": "CAIVRS & SAM"
        },
        "Sole Prop Certification": {
        "applicationName": "Loan",
        "documentTypeName": "Sole Prop Certificate"
        },
        "State Title Application": {
        "applicationName": "Loan",
        "documentTypeName": "State Title Application"
        },
        "Assumed Name Certificate": {
        "applicationName": "Loan",
        "documentTypeName": "Fictitious Or Assumed Name Cert"
        },
        "Borrower's Certification": {
        "applicationName": "Loan",
        "documentTypeName": "Borrower/OC Certification"
        },
        "Contingent Debt Schedule": {
        "applicationName": "Loan",
        "documentTypeName": "Contingent Debt Schedule"
        },
        "ETRAN Servicing Document": {
        "applicationName": "Loan",
        "documentTypeName": "ETRAN Servicing Document"
        },
        "Employment Authorization": {
        "applicationName": "Loan",
        "documentTypeName": "Employment Authorization"
        },
        "Etran Loan Auth Document": {
        "applicationName": "Loan",
        "documentTypeName": "Etran Loan Auth Document"
        },
        "Expected Completion Date": {
        "applicationName": "Loan",
        "documentTypeName": "Expected Completion Date"
        },
        "I-94 Form (Front & Back)": {
        "applicationName": "Loan",
        "documentTypeName": "I-94 Form"
        },
        "Incumbency Certification": {
        "applicationName": "Loan",
        "documentTypeName": "Incumbency Certification"
        },
        "Interest reserve details": {
        "applicationName": "Loan",
        "documentTypeName": "Interest reserve details"
        },
        "Most Recent Schedule K-1": {
        "applicationName": "Loan",
        "documentTypeName": "Schedule K-1"
        },
        "Seller Tax Return - 2021": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Sellers"
        },
        "Seller Tax Return - 2022": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Sellers"
        },
        "Seller Tax Return - 2023": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Sellers"
        },
        "Seller Tax Return - 2024": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Sellers"
        },
        "Seller Tax Return - 2025": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Sellers"
        },
        "Stock Purchase Agreement": {
        "applicationName": "Loan",
        "documentTypeName": "Purchase Agreement (Business/Stock/Asset)"
        },
        "Articles of Incorporation": {
        "applicationName": "Loan",
        "documentTypeName": "Articles of Incorporation"
        },
        "Certificate Of Trade Name": {
        "applicationName": "Loan",
        "documentTypeName": "Certificate Of Trade Name"
        },
        "Certificate of Trade Name": {
        "applicationName": "Loan",
        "documentTypeName": "Certificate Of Trade Name"
        },
        "Equipment Contract/Quotes": {
        "applicationName": "Loan",
        "documentTypeName": "Equipment Quote"
        },
        "Good Standing Certificate": {
        "applicationName": "Loan",
        "documentTypeName": "Certificate Of Good Standing"
        },
        "Lender Requested Document": {
        "applicationName": "Loan",
        "documentTypeName": "Lender Requested Document"
        },
        "Most Recent Annual Review": {
        "applicationName": "Loan",
        "documentTypeName": "Annual Review"
        },
        "Property Insurance Policy": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Business Personal Property"
        },
        "Purchase Agreement or LOI": {
        "applicationName": "Loan",
        "documentTypeName": "Purchase Agreement"
        },
        "60 Days Account Statements": {
        "applicationName": "Loan",
        "documentTypeName": "Bank Statements - Business/Personal"
        },
        "Agricultural Balance Sheet": {
        "applicationName": "Loan",
        "documentTypeName": "Agricultural Balance Sheet"
        },
        "Attorney Engagement Letter": {
        "applicationName": "Loan",
        "documentTypeName": "Attorney Engagement Letter"
        },
        "Business Tax Return - 2021": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Returns - Business"
        },
        "Business Tax Return - 2022": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Returns - Business"
        },
        "Business Tax Return - 2023": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Returns - Business"
        },
        "Business Tax Return - 2024": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Returns - Business"
        },
        "Business Tax Return - 2025": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Returns - Business"
        },
        "Certificate of Partnership": {
        "applicationName": "Loan",
        "documentTypeName": "Certificate of Partnership"
        },
        "Non-Solicitation Agreement": {
        "applicationName": "Loan",
        "documentTypeName": "Non-Solicitation Agreement"
        },
        "Personal Tax Return - 2021": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Personal"
        },
        "Personal Tax Return - 2022": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Personal"
        },
        "Personal Tax Return - 2023": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Personal"
        },
        "Personal Tax Return - 2024": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Personal"
        },
        "Personal Tax Return - 2025": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Personal"
        },
        "Purchase Agreement/Invoice": {
        "applicationName": "Loan",
        "documentTypeName": "Purchase Agreement"
        },
        "Year-to-Date Balance Sheet": {
        "applicationName": "Loan",
        "documentTypeName": "Balance Sheet"
        },
        "Bill of Sale (new purchase)": {
        "applicationName": "Loan",
        "documentTypeName": "Bill of Sale"
        },
        "Certificate Of Organization": {
        "applicationName": "Loan",
        "documentTypeName": "Certificate Of Organization"
        },
        "Certificate of Organization": {
        "applicationName": "Loan",
        "documentTypeName": "Certificate Of Organization"
        },
        "Closing Instructions Letter": {
        "applicationName": "Loan",
        "documentTypeName": "Correspondence - Closing"
        },
        "Environmental Questionnaire": {
        "applicationName": "Loan",
        "documentTypeName": "Environmental Questionnaire"
        },
        "Executed Purchase Agreement": {
        "applicationName": "Loan",
        "documentTypeName": "Purchase Agreement"
        },
        "Fictitious Name Certificate": {
        "applicationName": "Loan",
        "documentTypeName": "Fictitious Or Assumed Name Cert "
        },
        "General Liability Insurance": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Liability"
        },
        "Good Faith Deposit Document": {
        "applicationName": "Loan",
        "documentTypeName": "Good Faith Deposit Document"
        },
        "Required release provisions": {
        "applicationName": "Loan",
        "documentTypeName": "Required Release Provisions"
        },
        "12-Month Operating Statement": {
        "applicationName": "Loan",
        "documentTypeName": "Operating Statement"
        },
        "Assignment of Leases & Rents": {
        "applicationName": "Loan",
        "documentTypeName": "Collateral Assign Of Leases And Rents"
        },
        "Auto/Business Auto Insurance": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Automobile "
        },
        "Business/Personal Tax Return": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Returns - Business/Personal"
        },
        "Certificate Of Good Standing": {
        "applicationName": "Loan",
        "documentTypeName": "Certificate Of Good Standing"
        },
        "Certificate of Good Standing": {
        "applicationName": "Loan",
        "documentTypeName": "Certificate Of Good Standing"
        },
        "Construction Contract/Quotes": {
        "applicationName": "Loan",
        "documentTypeName": "Construction Bids"
        },
        "Life Insurance Questionnaire": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Life"
        },
        "Management Control Agreement": {
        "applicationName": "Loan",
        "documentTypeName": "Management Control Agreement"
        },
        "Manufacturers Specifications": {
        "applicationName": "Loan",
        "documentTypeName": "Manufacturers Specifications"
        },
        "Payment and Performance Bond": {
        "applicationName": "Loan",
        "documentTypeName": "Payment and Performance Bond"
        },
        "Personal Financial Statement": {
        "applicationName": "Loan",
        "documentTypeName": "Personal Financials"
        },
        "Signed 8821 Consent Document": {
        "applicationName": "Loan",
        "documentTypeName": "Tax  Verification (8821)"
        },
        "12-Months Operating Statement": {
        "applicationName": "Loan",
        "documentTypeName": "Operating Statement"
        },
        "Accounts Payable Aging Report": {
        "applicationName": "Loan",
        "documentTypeName": "Accounts Payable Aging Report"
        },
        "Contingent Liability Schedule": {
        "applicationName": "Loan",
        "documentTypeName": "Contingent Liability Schedule"
        },
        "Copy of Note to Refinance (1)": {
        "applicationName": "Loan",
        "documentTypeName": "Notes To Be Refinanced"
        },
        "Copy of Note to Refinance (2)": {
        "applicationName": "Loan",
        "documentTypeName": "Notes To Be Refinanced"
        },
        "Copy of Note to Refinance (3)": {
        "applicationName": "Loan",
        "documentTypeName": "Notes To Be Refinanced"
        },
        "Copy of Note to Refinance (4)": {
        "applicationName": "Loan",
        "documentTypeName": "Notes To Be Refinanced"
        },
        "Current Loan Payoff Statement": {
        "applicationName": "Loan",
        "documentTypeName": "Loan Payoff Statement"
        },
        "Franchise Disclosure Document": {
        "applicationName": "Loan",
        "documentTypeName": "Franchise Disclosure Document"
        },
        "Personal Financial Statements": {
        "applicationName": "Loan",
        "documentTypeName": "Personal Financials"
        },
        "Retirement Account Statements": {
        "applicationName": "Loan",
        "documentTypeName": "Proof of Income"
        },
        "Schedule Of Real Estate Owned": {
        "applicationName": "Loan",
        "documentTypeName": "Schedule Of Real Estate Owned"
        },
        "Affiliate Business Tax Returns": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Returns - Affiliate"
        },
        "Agreement to Provide Insurance": {
        "applicationName": "Loan",
        "documentTypeName": "Agreement to Provide Insurance"
        },
        "Assumed Name (DBA) Certificate": {
        "applicationName": "Loan",
        "documentTypeName": "Fictitious Or Assumed Name Cert"
        },
        "Franchise or Similar Agreement": {
        "applicationName": "Loan",
        "documentTypeName": "Franchise Documents"
        },
        "Most recent federal tax return": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Returns - Business/Personal"
        },
        "Non-Disclosure Agreement (NDA)": {
        "applicationName": "Loan",
        "documentTypeName": "Non-Disclosure Agreement (NDA)"
        },
        "Real Estate Property Insurance": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Real Estate Property"
        },
        "Seller's current debt schedule": {
        "applicationName": "Loan",
        "documentTypeName": "Debt Schedule"
        },
        "Business Interruption Insurance": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Business Interruption"
        },
        "Driver's License (Front & Back)": {
        "applicationName": "Loan",
        "documentTypeName": "State Issued ID/Drivers License"
        },
        "Primary Identification Document": {
        "applicationName": "Loan",
        "documentTypeName": "Primary Identification Document"
        },
        "State or County DBA Certificate": {
        "applicationName": "Loan",
        "documentTypeName": "Fictitious Or Assumed Name Cert "
        },
        "UCC Search Status Certification": {
        "applicationName": "Loan",
        "documentTypeName": "UCC Search"
        },
        "Worker's Compensation Insurance": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Workers Comp"
        },
        "Accounts Receivable Aging Report": {
        "applicationName": "Loan",
        "documentTypeName": "Accounts Receivable Aging Report"
        },
        "Federal Tax Return (most recent)": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Returns - Business/Personal"
        },
        "Form 1846, Statement of Lobbying": {
        "applicationName": "Loan",
        "documentTypeName": "Form 1846, Statement of Lobbying"
        },
        "General Liability (GL) Insurance": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Liability"
        },
        "Post Boarding Document - Officer": {
        "applicationName": "Loan",
        "documentTypeName": "Post Boarding Document - Officer"
        },
        "Proof of Real Estate Tax Payment": {
        "applicationName": "Loan",
        "documentTypeName": "Proof of Tax Payment"
        },
        "Assignment of Term Life Insurance": {
        "applicationName": "Loan",
        "documentTypeName": "Life Assignment & Acknowledgement"
        },
        "Borrower Pro Forma If Unavailable": {
        "applicationName": "Loan",
        "documentTypeName": "Borrower Pro Forma"
        },
        "DBA / Fictitious Name Certificate": {
        "applicationName": "Loan",
        "documentTypeName": "Fictitious Or Assumed Name Cert"
        },
        "Employee List and Payroll Summary": {
        "applicationName": "Loan",
        "documentTypeName": "Employee List and Payroll Summary"
        },
        "Interim Profit and Loss Statement": {
        "applicationName": "Loan",
        "documentTypeName": "Profit & Loss"
        },
        "Secondary Identification Document": {
        "applicationName": "Loan",
        "documentTypeName": "Secondary Identification Document"
        },
        "Seller Year-to-Date Balance Sheet": {
        "applicationName": "Loan",
        "documentTypeName": "Seller's Financials"
        },
        "Subsequent Modifications Approval": {
        "applicationName": "Loan",
        "documentTypeName": "Subsequent Modifications Approval"
        },
        "Business Tax Return for Prior Year": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Returns - Business"
        },
        "Business Tax Return for Prior year": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Returns - Business"
        },
        "Business Tax Return for prior year": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Business"
        },
        "Certificate of Limited Partnership": {
        "applicationName": "Loan",
        "documentTypeName": "Certificate of Limited Partnership"
        },
        "Executed mortgage or deed of trust": {
        "applicationName": "Loan",
        "documentTypeName": "Deed Trust"
        },
        "IRS Letter Regarding 501(C) Status": {
        "applicationName": "Loan",
        "documentTypeName": "IRS Letter - 501(C) Status"
        },
        "IRS Letter Regarding 501(c) status": {
        "applicationName": "Loan",
        "documentTypeName": "IRS Letter - 501(C) Status"
        },
        "Personal Tax Return for prior year": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Personal"
        },
        "Personal tax return for prior year": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Personal"
        },
        "Post Boarding Document - Depositor": {
        "applicationName": "Loan",
        "documentTypeName": "Post Boarding Document - Depositor"
        },
        "IRS Letter Regarding 501(C3) Status": {
        "applicationName": "Loan",
        "documentTypeName": "IRS Letter - 501(C3) Status"
        },
        "IRS Letter Regarding 501(c3) Status": {
        "applicationName": "Loan",
        "documentTypeName": "IRS Letter - 501(C3) Status"
        },
        "Line Item Budget and Cost Breakdown": {
        "applicationName": "Loan",
        "documentTypeName": "Line Item Budget and Cost Breakdown"
        },
        "Loan History for previous 12 months": {
        "applicationName": "Loan",
        "documentTypeName": "Loan History"
        },
        "Personal Tax Return (including K-1s)": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Personal"
        },
        "Property Insurance Declarations Page": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance Declaration Page - Business Personal Property"
        },
        "Certificate Of Title For Used Vessels": {
        "applicationName": "Loan",
        "documentTypeName": "Certificate Of Title - Vessels"
        },
        "Certificate of Title for used vessels": {
        "applicationName": "Loan",
        "documentTypeName": "Certificate Of Title - Vessels"
        },
        "Personal Tax Return for 2 years prior": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Personal"
        },
        "Purchase Agreement / Letter of Intent": {
        "applicationName": "Loan",
        "documentTypeName": "Purchase Agreement"
        },
        "State or Federal Government Issued ID": {
        "applicationName": "Loan",
        "documentTypeName": "State Issued ID/Drivers License"
        },
        "Workman's Compensation (WC) Insurance": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Workers Comp"
        },
        "Alien Registration Card (Front & Bank)": {
        "applicationName": "Loan",
        "documentTypeName": "US Permanent Resident Card (Green Card)"
        },
        "Business Tax Returns for 2 Years Prior": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Returns - Business"
        },
        "Business Tax Returns for 2 years prior": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Returns - Business"
        },
        "Signed document(s) from Manual closing": {
        "applicationName": "Loan",
        "documentTypeName": "Signed document(s) from Manual closing"
        },
        "UCC Statement Pre-filing Authorization": {
        "applicationName": "Loan",
        "documentTypeName": "UCC Search"
        },
        "Year-to-Date Profit and Loss Statement": {
        "applicationName": "Loan",
        "documentTypeName": "Profit & Loss"
        },
        "Beneficial Ownership Certification Form": {
        "applicationName": "Loan",
        "documentTypeName": "Beneficial Ownership Certification Form"
        },
        "Business Tax Returns for 2 years' prior": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Business"
        },
        "Hazard insurance (could be auto policy)": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Hazard"
        },
        "Limited Liability Partnership Agreement": {
        "applicationName": "Loan",
        "documentTypeName": "Limited Liability Partnership Agreement"
        },
        "Marketing plan & anticipated absorption": {
        "applicationName": "Loan",
        "documentTypeName": "Marketing Plan/Anticipated Absorption"
        },
        "Schedule K-1 on Guarantor (most recent)": {
        "applicationName": "Loan",
        "documentTypeName": "Schedule K-1"
        },
        "US Permanent Resident Card (Green Card)": {
        "applicationName": "Loan",
        "documentTypeName": "US Permanent Resident Card (Green Card)"
        },
        "Business Tax Return for most recent year": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Business"
        },
        "Personal tax return for most recent year": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Personal"
        },
        "Rent Roll & 12-Month Operating Statement": {
        "applicationName": "Loan",
        "documentTypeName": "Rent Roll/Operating Statement"
        },
        "Dram Shop/Host Liquor Liability Insurance": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Liquor"
        },
        "Most Recent Federal Tax Return - Business": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Returns - Business"
        },
        "Most Recent Federal Tax Return - Personal": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Personal"
        },
        "Officer Roster or Organization Resolution": {
        "applicationName": "Loan",
        "documentTypeName": "Officer Roster/Organization Resolution"
        },
        "Assignment of Tenant Improvement Allowance": {
        "applicationName": "Loan",
        "documentTypeName": "Assignment of Tenant Improvement Allowance"
        },
        "Environmental Questionnaire Phase I Report": {
        "applicationName": "Loan",
        "documentTypeName": "Environmental Report"
        },
        "Stock Certificates or Corporate Resolution": {
        "applicationName": "Loan",
        "documentTypeName": "Stock Certificates"
        },
        "Environmental Questionnaire Phase II Report": {
        "applicationName": "Loan",
        "documentTypeName": "Environmental Report"
        },
        "Hazard Insurance/Business Personal Property": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Business Personal Property"
        },
        "Hazard insurance/Business Personal Property": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Hazard"
        },
        "Personal Financial Statement - SBA Form 413": {
        "applicationName": "Loan",
        "documentTypeName": "Personal Financials"
        },
        "Assumed Name Certificate or Business License": {
        "applicationName": "Loan",
        "documentTypeName": "Assumed Name Certificate/Business License"
        },
        "Hazard Insurance (Could Be Marine Insurance)": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Hazard"
        },
        "Hazard insurance (could be Marine Insurance)": {
        "applicationName": "Loan",
        "documentTypeName": "Insurance - Hazard"
        },
        "Preliminary Review of Plans/Specs and Budget": {
        "applicationName": "Loan",
        "documentTypeName": "Preliminary Review of Plans/Specs and Budget"
        },
        "Seller's Business Tax Returns for prior year": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Sellers"
        },
        "Seller Year-to-Date Profit and Loss Statement": {
        "applicationName": "Loan",
        "documentTypeName": "Seller's Financials"
        },
        "Federal Tax Return for 1 year prior - Business": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Returns - Business"
        },
        "Federal Tax Return for 1 year prior - Personal": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Personal"
        },
        "Articles Of Incorporation (Dated And Certified)": {
        "applicationName": "Loan",
        "documentTypeName": "Articles of Incorporation"
        },
        "Articles of Incorporation (dated and certified)": {
        "applicationName": "Loan",
        "documentTypeName": "Articles of Incorporation"
        },
        "Federal Tax Return for 2 years prior - Business": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Returns - Business"
        },
        "Federal Tax Return for 2 years prior - Personal": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Personal"
        },
        "Seller's Business Tax Returns for 2 years prior": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Sellers"
        },
        "Signed Etran Loan Authorization (T&C) Documents": {
        "applicationName": "Loan",
        "documentTypeName": "Terms and Conditions "
        },
        "2 Years of Business Projections with Assumptions": {
        "applicationName": "Loan",
        "documentTypeName": "Business Projections with Assumptions"
        },
        "Copy of most recent Schedule K-1 on Guarantor(s)": {
        "applicationName": "Loan",
        "documentTypeName": "Schedule K-1"
        },
        "Manufacture Statement Of Origin, If New Purchase": {
        "applicationName": "Loan",
        "documentTypeName": "Manufacture Statement Of Origin"
        },
        "Manufacture Statement of Origin, if new purchase": {
        "applicationName": "Loan",
        "documentTypeName": "Manufacture Statement Of Origin"
        },
        "Most recent 6 months of Business Bank Statements": {
        "applicationName": "Loan",
        "documentTypeName": "Bank Statements - Business"
        },
        "Certificate of Organization (dated and certified)": {
        "applicationName": "Loan",
        "documentTypeName": "Certificate Of Organization"
        },
        "Seller's Business Tax Returns for most recent year": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Sellers"
        },
        "Verification Of Liquid Assets (Account Statements)": {
        "applicationName": "Loan",
        "documentTypeName": "Bank Statements - Business/Personal"
        },
        "Business Financial Statement or Business Tax Return": {
        "applicationName": "Loan",
        "documentTypeName": "Business Financial Statement/Tax Return"
        },
        "Articles Of Association With At Least Two Signatures": {
        "applicationName": "Loan",
        "documentTypeName": "Articles of Association"
        },
        "Articles of Association with at least two signatures": {
        "applicationName": "Loan",
        "documentTypeName": "Articles of Association"
        },
        "Business's most recent quarter-to-date Balance Sheet": {
        "applicationName": "Loan",
        "documentTypeName": "Balance Sheet"
        },
        "Individual K-1'S For Entities Reported On Schedule E": {
        "applicationName": "Loan",
        "documentTypeName": "Schedule K-1"
        },
        "Business Tax Return for most recent year or extension": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Business"
        },
        "IRS SS4 TIN Issuance Letter With Correct Name And EIN": {
        "applicationName": "Loan",
        "documentTypeName": "IRS SS4 TIN Issuance Letter"
        },
        "IRS SS4 TIN Issuance Letter with correct name and EIN": {
        "applicationName": "Loan",
        "documentTypeName": "IRS SS4 TIN Issuance Letter"
        },
        "Personal tax return for most recent year or extension": {
        "applicationName": "Loan",
        "documentTypeName": "Tax Return - Personal"
        },
        "Business's most recent quarter-to-date Income Statement": {
        "applicationName": "Loan",
        "documentTypeName": "Business Income Statement"
        },
        "Operating Agreement (if ownership percentage is stated)": {
        "applicationName": "Loan",
        "documentTypeName": "Operating Agreement"
        },
        "2 Years' Business Financial Projections with Assumptions": {
        "applicationName": "Loan",
        "documentTypeName": "Business Projections with Assumptions"
        },
        "Certificate of Organization or Articles of Incorporation": {
        "applicationName": "Loan",
        "documentTypeName": "Certificate Of Organization"
        },
        "General Contractor details, including bonding requirements": {
        "applicationName": "Loan",
        "documentTypeName": "General Contractor details, including bonding requirements"
        },
        "Current Year Social Security Award Letter And Other Retirement Income": {
        "applicationName": "Loan",
        "documentTypeName": "Social Security Award Letter/Other Retirement Income"
        },
        "Seller's most recent quarter-to-date income statement & balance sheet": {
        "applicationName": "Loan",
        "documentTypeName": "Seller's Financials"
        },
        "Meeting minutes appointing signers and signed by Association Secretary": {
        "applicationName": "Loan",
        "documentTypeName": "Meeting minutes appointing signers and signed by Association Secretary"
        },
        "Pre-Sold Inventory Details, Executed Sales Contracts, Letters Of Intent": {
        "applicationName": "Loan",
        "documentTypeName": "Pre-Sold Inventory Details, Executed Sales Contracts, Letters Of Intent"
        },
        "Most Recent Paystubs Showing Year To Date Income For Pay Period Covering 30 Days": {
        "applicationName": "Loan",
        "documentTypeName": "Pay Stubs"
        },
        "Lot/Unit Breakdown (including retail sales prices and breakdown of pre-sold vs. spec)": {
        "applicationName": "Loan",
        "documentTypeName": "Lot/Unit Breakdown"
        },
        "Evidence that the ESOP is in compliance with all applicable IRS, Treasury, and Department of Labor requirements": {
        "applicationName": "Loan",
        "documentTypeName": "Evidence ESOP is in Compliance"
        },
        "Evidence that the ESOP is in compliance with all applicable IRS, Treasury, and Department of Labor requirements.": {
        "applicationName": "Loan",
        "documentTypeName": "Evidence ESOP is in Compliance"
        },
        "Flood Search, Appraisal Report, Environmental due diligence, title work, etc. (must be already available/tracked separately)": {
        "applicationName": "Loan",
        "documentTypeName": "Flood Search, Appraisal Report, Environmental Due Diligence, Title Work, etc."
        }
    },
    "response_body_spec_config": "{}"
    }
}

org_config = (
    OrganizationConfiguration.objects.all().order_by("-version_major", "-version_minor", "-version_patch").first()
)
for key, value in interfaces.items():
    configuration, _ = Configuration.objects.update_or_create(
        name=key, interface_type=key, defaults={"details": value}
    )
    org_config.details["GLOBAL"][key] = {"name": configuration.name, "version": configuration.version}
    org_config.save()