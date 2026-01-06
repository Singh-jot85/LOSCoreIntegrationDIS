((
    { "principal_and_interest": 0, "interest_only": 2}
) as $repaymentTypeMapping |
(
    { "310": 1, "320": 0, "201": 3}
) as $accuralMapping |
{
    AccountId: {
        AcctId: (.loan_number // ""),
        AcctType: "L"
    },
    LnAdd: {
        LnInfoRec: {
            Term: {
                TermCnt: (.loan_approval.approved_term // null),
                TermUnits: "Months"
            },
            RemPmtCnt: (.loan_approval.approved_term // null),
            PmtTerm: "001",
            PmtDayOfMonth:( 
                if (
                    (.loan_approval.approved_first_payment_date | split("-")[2] == "29")
                    or (.loan_approval.approved_first_payment_date | split("-")[2] == "30")
                    or (.loan_approval.approved_first_payment_date | split("-")[2] == "31")
                ) then (.loan_approval.approved_first_payment_date) 
                else null 
                end
            ),
            PmtCode: (((.pricing_details[] | select(.term_position == "term_1") | $repaymentTypeMapping[.repayment_type]) // null)),
            PmtAmt: (
                (.loan_interfaces[] 
                | select(.is_latest==true and .interface_type=="sherman") 
                |(
                    (.details.outLOAN_BUILDER.AmTable.AmLine[] 
                    | select(.Idx=="1")) | .Pmt | tonumber // null
                ))
            ),
            PIAmt: ((
                .loan_interfaces[] | select(.is_latest==true and .interface_type=="sherman") 
                |((.details.outLOAN_BUILDER.AmTable.AmLine[] 
                | select(.Idx=="1")) | .Pmt | tonumber // null)
            )),
            OrigBal: (.approved_amount // ""),
            OpenDt: (now | strftime("%Y-%m-%d")),
            OffCode: (.details.cra_details?.branch_code // ""),
            NxtSchedPmtDt: (.loan_approval.approved_first_payment_date // ""),
            MatDt: (.maturity_date // ""),
            IntRate: (.loan_approval.approved_rate/100 // ""),
            IntBasis: ($accuralMapping[.accrual_method | tostring] // null),
            BrCode: "51",
            ProdCode: "26",
            AcctStat: "4",
            CustId: (.loan_relations[] | select(.is_primary_borrower == true) | .external_customer_id // ""),
            OddDaysIntBasis: "B"
        },
        LnAcctInfo: {
            VehicleId: ((.collaterals[] | select(.category=="vehicles") | .details.vin) // null),
            SubPrimeLnCode: "N",
            State: (.loan_relations[] | select(.is_primary_borrower == true) | .state_of_establishment // ""),
            PurpCode: "98",
            PrtPastDueNotCode: "Y",
            PrtCouponBook: "N",
            OrigLnToValRatio: (if .approved_amount and .total_collateral_value_v2 then ((.approved_amount / .total_collateral_value_v2)* 10000  | round  / 10000) else null end),
            LateChgCode: "CL1",
            DeptCode: "C",
            CurLnToValRatio: (if .approved_amount and .total_collateral_value_v2 then ((.approved_amount / .total_collateral_value_v2)* 10000  | round  / 10000) else null end),
            CrRatingCode: "5",
            CollatCode: "14",
            AnnIncmAmt: (.cra_gross_annual_revenue // null),
            AcctClsfCode: "Q",
            CombLTV: (if .approved_amount and .total_collateral_value_v2 then ((.approved_amount / .total_collateral_value_v2)* 10000  | round  / 10000) else null end),
            CrScoreId: (.fico_score // null),
            MoIncmAmt: ((.cra_amount/12) | round // null),
            NumBorw: ( ([.loan_relations[] | select(.relation_type == "borrower")] | length) // null),
            LangType: "English",
            CrRatingCode: "5",
            BorwInfoArray: {
                BorwInfo: {
                    BorwFICOId: (.fico_score // null)
                }
            },
            CrBureauRptCode: "N"
        },
        LnBalDtInfo: {
            FirstPmtDt: (.loan_approval.approved_first_payment_date // ""),
        },
        LnPmtInfo: {
            UsePmtSusp: "N",
            BilLeadDays: "15"
        },
        LnRateInfo: {
            RateVarCode: ( 
                .pricing_details[] | select(.term_position == "term_1") 
                |(
                    if .differential_rate == null 
                        then null
                    else
                        if .differential_rate > 0
                            then "Positive"
                        elif .differential_rate < 0
                            then "Negative"
                        else null
                        end
                    end
                )
            ),
            RateRevTermUnits: "day",
            RateRevTerm: 1,
            OrigIdxVal: ((.pricing_details[] | select(.term_position == "term_1") | (.prime_rate)/100) // null),
            RateVar: (
                (.pricing_details[] | select(.term_position == "term_1") | (.differential_rate)/100) // null
            ),
            RateFlr: (if(.max_rate) then (.min_rate /100) *100 | round / 100 else null end ),
            RateCeil: (if(.max_rate) then .max_rate /100 else null end),
        },
        LnRealEstateInfo: (.collaterals[0] | 
            { 
                PropStreet: ( .collateral_address |  "\(.address_line_1) \(.address_line_2)"),
                FloodInsurCode: (
                    if .collaterals[0].is_flood_search_required == true
                        then "Y"
                    elif .collaterals[0].is_flood_search_required == false
                        then "N"
                    else null
                    end
                ),
                ApprDt: ( if (.is_appraisal_required == true) then .collateral_appraisal.details?.report_due_date else null end),
                PropCounty: (.collateral_address | .county // null ),
                PropState: ( .collateral_address | .state // null ),
                PropPostalCode: (.collateral_address | .zip_code // null ),
                PropCity: (.collateral_address | .city // null ),
                ApprVal: ( if (.is_appraisal_required == true) then .collateral_appraisal.details.report_price else null end // null )
            }
        ),
        LnRegRptInfo: {
            NAICSCode: (.loan_relations[] | select(.is_primary_borrower == true) | .naics_code // null),
            CRARec: (
                .details.geocoding_details[0] | 
                {
                    CRAStateCode: (.details.cra_details?.state_code // null),
                    CRACountyCode: (.county_code // null),
                    CRACenTract: (.tract_code // null),
                    CRASMSACode: (.MSA_code // null),
                    CRALoc: 1,
                    CRAIncmLvl: 1
                }
            ),
            CallRptCode: "4A",
            Req1098: "NotReq",
            SBAGuarPct: ((if (.product.product_code | IN("EL_LOC","EL_TL","7A_TL")) then .sba_express_details.sba_guaranty_percent /100 else null end)),
            SBAGuarId: (if (.product.product_code | IN("EL_LOC","EL_TL","7A_TL")) then .sba_number else null end),
            SBABasisPts: (if (.product.product_code | IN("EL_LOC","EL_TL","7A_TL")) then (if (.approved_amount <= 150000) then 1.50 else 3.00 end) else null end)
        }
    }
}
)