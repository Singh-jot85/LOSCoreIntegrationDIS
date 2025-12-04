(
    ({
        "310": "Actual360",
        "320": "Actual365",
        "201": "Even30DayMonths360",
        "311": "Even30DayMonths365"
    }) as $accrualMapping |
    ({
        "principal_only": "FixedPrincipal",
        "principal_and_interest": "PrincipalAndInterest",
        "interest_only": "InterestOnly"
    }) as $repaymentTypeMapping |
    ({
        "Wall Street Journal Prime": "WallStreetJournalPrime",
        "Federal Home Loan Banks": "FederalHomeLoanBankBoard",
        "US Treasury Securities Rate": "Treasury10Year",
        "Treasury Constant Maturities": "CMT10Year",
        "SOFR": "Other"
    }) as $rateIndexMapping | 
    ({
        "1": "Annually",
        "3": "Every3Years",
        "5": "Every5Years",
        "7": "Every7Years",
        "10": "Every10Years",
    }) as $adjustmentPeriodMapping | 
    {
        interestStartDate: (
            if (.funding_date == null or .funding_date == "")
                then (.closing_date // null)
            else null
            end
        ),
        interestStartDateType: (
            if (.funding_date == null or .funding_date == "")
                then "NoteDate"
            else null
            end
        ),
        noteDate: (.closing_date // null),
        amountFinanced: ((.approved_amount) // null),
        firstPaymentDate: ((.loan_approval.approved_first_payment_date) // null),
        fundingDate: ((.funding_details.funding_date) // null),
        initialDisbursement: (((.loan_approval.approved_amount // 0) - (.disbursements.remaining_amount // 0)) // null),
        interestRatePercent: ((.loan_approval.approved_rate) // null),
        loanId: ((if .loan_number then .loan_number | tonumber else null end) // null),
        maturityDate: ((.maturity_date) // null),
        rateType: (.pricing_details[] | select(.term_position == "term_1") | (.rate_type) // null),
        adjustmentPeriod: (
            .pricing_details[]
            | select(.term_position == "term_1")
            | .rate_change_frequency_type as $freqType
            | if ($freqType == "Calendar Quarterly")
                then "CalendarQuarter"
            elif $freqType == "Years"
                then $adjustmentPeriodMapping[.rate_change_frequency_number | tostring]
            else $freqType
            end
        ),
        balloonPaymentAmount: ( if( .product.product_code == "SB_TL" and(
        .pricing_details | map( select(
        (.repayment_type == "principal_and_interest")
        and (.amortization_in_months > .term_in_months))) |  length > 0 ) ) 
        then (
            .loan_interfaces[]
            | select(
                .interface_type == "sherman"
                and .is_latest == true
                and .details.outLOAN_BUILDER?
                and .details.outLOAN_BUILDER.AmTable?
                and .details.outLOAN_BUILDER.AmTable.AmLine?
        ) | (.details.outLOAN_BUILDER.AmTable.AmLine | max_by(.Idx) | .Pmt | tonumber)
        ) else null end ),
        finalPayment: (.pricing_details[] | select(.term_position == "term_1") | 
            if .repayment_type == "interest_only"
                then "DueOnRegularDueDate"
            else null
            end // null 
        ),
        firstPAndIPaymentAmount: (if(.product.product_code == "SB_TL" or .product.product_code == "7A_TL")  then ( .loan_interfaces[] | select(
            .interface_type == "sherman"
            and .is_latest == true
            and .details.outLOAN_BUILDER.AmTable?
            and .details.outLOAN_BUILDER.AmTable.AmLine?
        ) | .details.outLOAN_BUILDER.AmTable.AmLine[] | select(.Idx == "1") | .Pmt | tonumber)
        else null end
        ),
        firstPAndIPaymentDate: (.loan_approval.approved_first_payment_date // null),
        fixedPrincipalAmount: (null),
        guarantyPercent: ((.sba_express_details.sba_guaranty_percent) // null),
        indexBaseRatePercent: (.pricing_details[] | select(.term_position == "term_1") | .prime_rate // null) ,
        interestBasis: ($accrualMapping[ .accrual_method | tostring] // null),
        interestRateCeilingPercent: ((.max_rate) // (.product.max_rate)),
        interestRateFloorPercent: ((.min_rate) // (.product.min_rate)),
        interestRateSpreadPercent: ((.differential_rate) // null),
        interestRoundingMethod: (null),
        interestRoundingPerDiem: (null),
        lineOfCredit:  (
            if (.product.product_code | IN("SB_LOC","EL_LOC"))
                then true 
            else false 
            end
        ),
        loanIdentifier: ((.core_integration_response.create_loan.response.responses.AccountNumber) // null | tostring),
        nextInterestAdjustmentDate: (null),
        nextReamortizationDate: (null),
        paymentAmount: ((.loan_interfaces[]? | select(.interface_type == "sherman" and .is_latest == true) | .details.outLOAN_BUILDER.AmTable.AmLine[]? | select(.Idx == "1" ) | .Pmt | tonumber ) // null),
        paymentFrequency: (.pricing_details[] | select(.term_position == "term_1") | .frequency // null),
        paymentLateFeePercent: (null),
        paymentType: (.pricing_details[] | select(.term_position == "term_1") | $repaymentTypeMapping[.repayment_type] // null ),
        rateIndex: (
            (.pricing_details[] 
            | select(.term_position == "term_1" and .rate_index!=null) 
            | if .index_period_type != null then
                if (.index_period_type <= 5 and .rate_index == "US Treasury Securities Rate") 
                    then  ("Treasury5Year")
                elif (.index_period_type <= 5 and .rate_index == "Treasury Constant Maturities") 
                    then ("CMT5Year")
                else null 
                end
            else $rateIndexMapping[.rate_index]
            end) // null
        ),
        reamortizationPeriod: (null),
        revolvingTermEndDate: (.revolving_term_end_date // null),
        sba1502Status: (null),
    }
)