((
    { "principal_and_interest": 0, "interest_only": 1}
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
                TermCnt: (.loan_approval.approved_term // ""),
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
            OffCode: "JHA",
            NxtSchedPmtDt: (.loan_approval.approved_first_payment_date // ""),
            MatDt: (.maturity_date // ""),
            IntRate: (.loan_approval.approved_rate/100 // ""),
            IntBasis: ($accuralMapping[.accrual_method | tostring] // null),
            BrCode: "51",
            ProdCode: "26",
            AcctStat: "4",
            CustId: (.loan_relations[] | select(.is_primary_borrower == true) | .external_customer_id // "")
        },
        LnAcctInfo: {
            PurpCode: "98",
            CrRatingCode: "5",
            CollatCode: "14",
            NumBorw: (([.loan_relations[] | select(.relation_type == "borrower")] | length) // null),
        },
        LnBalDtInfo: {
            OrigMatDt: (.maturity_date // ""),
            FirstPmtDt: (.loan_approval.approved_first_payment_date // ""),
            BalDueAtMat: "True"
        },
        LnDlrInfo: {
            FrftDiscAtPayoff: "R"
        },
        LnPmtInfo: {
            PostSeq5Code: "Escrow",
            PostSeq4Code: "Other charge",
            PostSeq3Code: "Late charge",
            PostSeq2Code: "Principal",
            PostSeq1Code: "Interest",
            IgnrLateChgMulti: "LateChg",
            BilLeadDays: "15",
            BallPmtAmt: "0",
            PostPmtPrePaidCode: "Y",
            PostPrincCurtCode: "N"
        },
        LnRateInfo: {
            RateVar: ((.pricing_details[] | select(.term_position == "term_1") | .differential_rate) // null),
            RateFlr: (.min_rate // null),
            RateCeil: (.max_rate // null),
            MatRate: "0"
        },
        LnRealEstateInfo: {
            PropState: (
                ([.loan_relations[] | 
                select(.is_primary_borrower == true and( (.collaterals | length) > 0))
                | .collaterals[0]
                | .collateral_addresses[0]
                | .state][0] // null)
            ),
            PropPostalCode: (
                ([.loan_relations[]
                | select(.is_primary_borrower == true and (.collaterals | length) > 0)
                | .collaterals[0]
                | .collateral_addresses[0]
                | .zip_code][0] // null)
            ),
            PropCity: (
                ([.loan_relations[]
                | select(.is_primary_borrower == true and (.collaterals | length) > 0)
                | .collaterals[0]
                | .collateral_addresses[0]
                | .city][0] // null)
            ),
            ApprVal: (
                ([.loan_relations[] 
                | select(.is_primary_borrower == true and (.collaterals | length) > 0)
                | .collaterals[0]
                | .collateral_appraisal.details.report_price][0] // null)
            )
        },
        LnRegRptInfo: {
            NAICSCode: (.account_naics_code // null),
            CallRptCode: "4A",
            Req1098: "N",
            SBAGuarPct: (.sba_express_details.sba_guaranty_percent // null),
            SBAGuarId: (.sba_number // null),
            SBABasisPts: (if (.approved_amount <= 150000) then 1.50 else 3.00 end // null)
        }
    }
}
)