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
            PmtTerm: "001",
            PmtDayOfMonth:( if (
                (.loan_approval.approved_first_payment_date | split("-")[2] == "29")
                or (.loan_approval.approved_first_payment_date | split("-")[2] == "30")
                or (.loan_approval.approved_first_payment_date | split("-")[2] == "31")
                ) then 
                    (.loan_approval.approved_first_payment_date) 
                else null 
                end
            ),
            PmtCode: (
                ((.pricing_details[] 
                | select(.term_position == "term_1")
                | $repaymentTypeMapping[.repayment_type]) // null)
            ),
            PmtAmt: (
                (.loan_interfaces[] 
                | select(.is_latest==true and .interface_type=="sherman") 
                |(
                    (.details.outLOAN_BUILDER.AmTable.AmLine[] 
                    | select(.Idx=="1")) | .Pmt | tonumber // null)
                )
            ),
            PIAmt: (
                (.loan_interfaces[] 
                | select(.is_latest==true and .interface_type=="sherman") 
                |(
                    (.details.outLOAN_BUILDER.AmTable.AmLine[] 
                    | select(.Idx=="1")) | .Pmt | tonumber // null)
                )
            ),
            OrigBal: (.approved_amount // ""),
            OpenDt: (now | strftime("%Y-%m-%d")),
            OffCode: (.boarding_details.branch_code // null),
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
            VehicleId: (
                if any(.collaterals[]; .category=="vehicles")
                    then "VIN"
                else null
                end
            ),
            SubPrimeLnCode: "N",
            State: (.loan_relations[] | select(.is_primary_borrower == true) | .state_of_establishment // ""),
            PurpCode: "98",
            PrtPastDueNotCode: "Y",
            OrigLnToValRatio: (.approved_amount // null),
            LateChgCode: "CL1",
            DeptCode: "C",
            CurLnToValRatio: (.approved_amount // null),
            CrRatingCode: "5",
            CollatCode: "14",
            AnnIncmAmt: (.cra_gross_annual_revenue // null),
            AcctClsfCode: "Q",
            CombLTV: (.approved_amount // null),
            CrScoreId: (.fico_score // null),
            MoIncmAmt: (.cra_gross_annual_revenue/12 // null),
            NumBorw: ( ([.loan_relations[] | select(.relation_type == "borrower")] | length) // null),
            TotDebtPct: null,
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
                .pricing_details[] | 
                select(.term_position == "term_1") | 
                if .margin > 0
                    then "Positive"
                elif .margin < 0
                    then "Negative"
                else null
                end
            ),
            RateRevTermUnits: "day",
            RateRevTerm: 1,
            OrigIdxVal: ((.pricing_details[] | select(.term_position == "term_1") | .prime_rate) // null),
            RateVar: ((.pricing_details[] | select(.term_position == "term_1") | .differential_rate) // null),
            RateFlr: (.min_rate // null),
            RateCeil: (.max_rate // null),
        },
        LnRealEstateInfo: (
            .collaterals[0] | 
            {    
                PropStreet: (
                    .collateral_addresses[0] |
                    select(.address_type == "permanent") |
                    "\(.address_line_1) \(.address_line_2)"
                ),
                FloodInsurCode: (
                    if .collaterals[0].is_flood_search_required == true
                        then "Y"
                    elif .collaterals[0].is_flood_search_required == false
                        then "N"
                    else null
                    end
                ),
                ApprDt: ( .collaterals[0] | .collateral_appraisal.details?.report_due_date // null ),
                OccupCode: null,
                PropCounty: ( .collaterals[0] | .collateral_addresses[0] | .county // null ),
                PropState: ( .collaterals[0] | .collateral_addresses[0] | .state // null ),
                PropPostalCode: ( .collaterals[0] | .collateral_addresses[0] | .zip_code // null ),
                PropCity: ( .collaterals[0] | .collateral_addresses[0] | .city // null ),
                ApprVal: ( .collaterals[0] | .collateral_appraisal.details.report_price // null )
            }
        ),
        LnRegRptInfo: {
            NAICSCode: (.account_naics_code // null),
            CRARec: (
                .details.cra_details | 
                {
                    CRAStateCode: (.cra_state_code // null),
                    CRACountyCode: (.cra_country_code // null),
                    CRACenTract: (.tract_code // null),
                    CRASMSACode: (.MSA_code // null),
                    CRALoc: (.address // null),
                }
            ),
            CallRptCode: "4A",
            Req1098: "N",
            SBAGuarPct: (.sba_express_details.sba_guaranty_percent // null),
            SBAGuarId: (.sba_number // null),
            SBABasisPts: (if (.approved_amount <= 150000) then 1.50 else 3.00 end // null)
        }
    }
}
)