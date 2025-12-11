{
    borrowerData: {
        accountNumber: ((if .loan_number != null then (.loan_number | tonumber) else null end) // null),
        address1: ((.loan_relations[] | select(.is_primary_borrower == true) | .relation_addresses[] | select(.address_type == "permanent") | (.address_line_1 + " " +.address_line_2 ) | ascii_upcase) // null),
        reportingStatusCode: $reportingStatusCode,
        tinCode: ((.loan_relations[] | select(.is_primary_borrower == true) | $tinCode[.tin_type]) // null),
        tinNumber: ((.loan_relations[] | select(.is_primary_borrower == true) | .tin) // null),
        address2: ((.loan_relations[] | select(.is_primary_borrower == true) | .relation_addresses[] | select(.address_type == "permanent") | (if.zip_code_plus4 != null then (.city + " " + .state + " " + .zip_code + "-" + .zip_code_plus4) | ascii_upcase else (.city + " " + .state + " " + .zip_code) | ascii_upcase end)) // null),
        address3: null,
        country: ((.loan_relations[] | select(.is_primary_borrower == true) | .relation_addresses[] | select(.address_type == "permanent") | .country | ascii_upcase) // null),
        name2TIN: ((.loan_relations[] | select(.borrower_position == 2) | .tin) // null),
        name2TINCode: ((.loan_relations[] | select(.borrower_position == 2) | $tinCode[.tin_type]) // null),
        phoneNumber: ((.loan_relations[] | select(.is_primary_borrower == true) | (if .work_phone != null then .work_phone|tostring elif .cell_phone != null then .cell_phone|tostring else .home_phone|tostring end)) // null),
        officerBorrower: ((if (.details and .details.boarding_details and .details.boarding_details.officerBorrower) then .details.boarding_details.officerBorrower else null end) // null),
        reportingStatusCode2: ((.loan_relations[] | select(.borrower_position == 2) | "W") // null),
        businessPhone: ((.loan_relations[] | select(.is_primary_borrower == true) | (if .party_type == "entity" then .work_phone|tostring else null end)) // null),
        birthDate: ((.loan_relations[] | select(.is_primary_borrower == true) | .dob) // null),
        birthDate2: ((.loan_relations[] | select(.borrower_position == 2) | .dob) // null),
        branchCode: ((if (.details and .details.boarding_details and .details.boarding_details.branchCode) then .details.boarding_details.branchCode else null end) // null),
        name1First: ((.loan_relations[] | select(.is_primary_borrower == true) | (if ((.party_type == "individual" or .tin_type == "SSN") and .first_name != null) then (.first_name | split("")) | map(if test("[[:punct:]]") then if . == "&" then "&" else "" end else . end | ascii_upcase) | join("") else (.business_name | split("")) | map(if test("[[:punct:]]") then if . == "&" then "&" else "" end else . end | ascii_upcase) | join("") end)) // null),
        name1Middle: ((.loan_relations[] | select(.is_primary_borrower == true) | (if ((.party_type == "individual" or .tin_type == "SSN") and .middle_name != null) then (.middle_name | split("")) | map(if test("[[:punct:]]") then if . == "&" then "&" else "" end else . end | ascii_upcase) | join("") else null end)) // null),
        name1Last: ((.loan_relations[] | select(.is_primary_borrower == true) | (if ((.party_type == "individual" or .tin_type == "SSN") and .last_name != null) then (.last_name | split("")) | map(if test("[[:punct:]]") then if . == "&" then "&" else "" end else . end | ascii_upcase) | join("") else null end)) // null),
        name2First: ((.loan_relations[] | select(.borrower_position == 2) | (if ((.party_type == "individual" or .tin_type == "SSN") and .first_name != null) then (.first_name | split("")) | map(if test("[[:punct:]]") then if . == "&" then "&" else "" end else . end | ascii_upcase) | join("") else (.business_name | split("")) | map(if test("[[:punct:]]") then if . == "&" then "&" else "" end else . end | ascii_upcase) | join("") end)) // null),
        name2Middle: ((.loan_relations[] | select(.borrower_position == 2) | (if ((.party_type == "individual" or .tin_type == "SSN") and .middle_name != null) then (.middle_name | split("")) | map(if test("[[:punct:]]") then if . == "&" then "&" else "" end else . end | ascii_upcase) | join("") else null end)) // null),
        name2Last: ((.loan_relations[] | select(.borrower_position == 2) | (if ((.party_type == "individual" or .tin_type == "SSN") and .last_name != null) then (.last_name | split("")) | map(if test("[[:punct:]]") then if . == "&" then "&" else "" end else . end | ascii_upcase) | join("") else null end)) // null),
        emailAddress: ((.loan_relations[] | select(.is_primary_borrower == true) | (if .party_type == "entity" then (if .children| length>0 then (.children[] | select(.relation_type == "representative") | (if .email != null then .email | ascii_upcase else null end)) else null end) else (if .email != null then .email | ascii_upcase else null end) end) ) // null)
    },
    noteData: {
        accountNumber: ((if .loan_number != null then (.loan_number | tostring) else null end) // null),
        noteNumber: $noteNumber,
        reportCodeFlag: $reportCodeFlag,
        iglCode: $iglCode,
        noteDate: ((if (now | strftime("%Y-%m-%d")) < (.closing_date) then (now | strftime("%Y-%m-%d")) else .closing_date end) // null),
        noteAmount: ((if .product.product_code == "SB_LOC" then 0 else .approved_amount end) // null),
        interestRate: ((.loan_approval.approved_rate) // null),
        accrualMethodThisNote: $accrualMethodThisNote,
        noteType: ((if .product.product_type.product_type_code == "TL" then "3" elif .product.product_type.product_type_code == "LOC" then "4" else null end) // null),
        paymentFrequency: $paymentFrequency,
        dateFirstDue: ((.payment_start_date) // null),
        maturityDate: ((.maturity_date) // null),
        officer: ((if (.details and .details.boarding_details and .details.boarding_details.officerBorrower) then .details.boarding_details.officerBorrower else null end) // null),
        branchCode: ((if (.details and .details.boarding_details and .details.boarding_details.branchCode) then .details.boarding_details.branchCode else null end) // null),
        controlCat: ((if .product.product_code == "EL_TL" or .product.product_code == "EL_LOC" then "M" else "C" end) // null),
        collateral1Code: (( [.collaterals[] ] as $collateralList | if(any($collateralList[] .collateral_type_verbose == "All Assets")) then $collateralCode["collateral1Code"] else ((if $collateralList | length > 0 then ($collateralList[0] | $collateralCode[.collateral_type_verbose]) else null end)) end ) // null),
        collateral2Code: (( [.collaterals[] ] as $collateralList | if(any($collateralList[] .collateral_type_verbose == "All Assets")) then $collateralCode["collateral2Code"] else ((if $collateralList | length > 1 then ($collateralList[1] | $collateralCode[.collateral_type_verbose]) else null end)) end ) // null),
        collateral3Code: (( [.collaterals[] ] as $collateralList | if(any($collateralList[] .collateral_type_verbose == "All Assets")) then $collateralCode["collateral3Code"] else ((if $collateralList | length > 2 then ($collateralList[2] | $collateralCode[.collateral_type_verbose]) else null end)) end ) // null),
        collateral4Code: (( [.collaterals[] ] as $collateralList | if(any($collateralList[] .collateral_type_verbose == "All Assets")) then $collateralCode["collateral4Code"] else ((if $collateralList | length > 3 then ($collateralList[3] | $collateralCode[.collateral_type_verbose]) else null end)) end ) // null),
        class: $class,
        rateControlCode: $rateControlCode,
        rateReviewInterval: $rateReviewInterval,
        marginAboveBelowBase: ((.differential_rate) // null),
        marginSign: $marginSign,
        lateChargeCode: ((if .product.product_code == "EL_TL" or .product.product_code == "EL_LOC" then $lateChargeCode else null end) // null),
        propertyDescription: null,
        creditScore1: (if .ficoSBSS70TotalScore then .ficoSBSS70TotalScore else null end),
        creditScore2: null,
        committedLiability: ((if .product.product_type.product_type_code == "LOC" then .approved_amount else null end) // null),
        callRPTStmtOfCond: $callRPTStmtOfCond,
        doNotDeleteCode: ((if .product.product_type.product_type_code == "LOC" then "1" else null end) // null),
        roundingFactor: $roundingFactor,
        undisbursedCreditLineCode: ((if .product.product_type.product_type_code == "LOC" then "R" else null end) // null),
        rateFloor: ((.product.min_rate) // null),
        rateCeiling: ((.product.max_rate) // null),
        propertyDescription2: null,
        propertyDescription3: null,
        propertyDescription4: null,
        creditBureauDoNotReport: $creditBureauDoNotReport
    },
    customerRelationships: [if any(.loan_relations[]; select(.borrower_position == 2)) == false 
        then (.loan_relations[] | if(.is_primary_borrower == true) 
            then {
                relationship: (($relationship["single"]) // null),
                customerGuid: ((.external_customer_id) // null)
            }
            else empty end)
        elif (any(.loan_relations[]; select(.borrower_position == 2)) == true) 
        then (.loan_relations[] | if(.is_primary_borrower == true) 
            then {
                relationship: $relationship["primary"],
                customerGuid: ((.external_customer_id) // null)
            }
            else empty end)
        else empty end
    ]
}