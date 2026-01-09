(
    {
        LOCAdd: {
            LOCAcctId: (.loan_number // ""),
            LOCAcctType: "L",
            LOCCustId: (
                .loan_relations[]
                | select(.is_primary_borrower == true)
                | .external_customer_id // ""
            ),
            LOCRec: {
                LOCAmt: ( .approved_amount // "" ),
                LOCExpDt: ( .maturity_date // ""),
                LOCCode: 1,
                LOCMainLOCId: "",
                LOCStat: 1,
                LOCBrCode: 51,
                LOCOffCode: (.details.cra_details?.branch_code // ""),
                LOCPrtcpCode: "",
                LOCDDAProtAmt: "",
                LOCFrzAmt: "",
                LOCTaxRefId: "",
                LOCOrigTerm: (.term_in_months // ""),
                LOCOrigTermUnit: "Months",
                LOCOrigAmt: ( .approved_amount // "" ),
                LOCInfo: "",
                LOCPrtCnsldtStmt: "N",
                LOCStmtDay: "",
                LOCStmtFreq: "",
                LOCStmtFreqCode: "",
                LOCSemiDay1: "",
                LOCSemiDay2: "",
                LOCCallRptCode: "4A",
                LOCCollatCode: 14,
                LOCRiskCode: "",
                LOCLastStmtDt: "",
                LOCLastMainDt: "",
                LOCCurBal: ( .approved_amount // "" ),
                LOCTotAdvaAmt: ( .approved_amount // "" ),
                LOCAvlBal: ( .approved_amount // "" ),
                LOCCommBal: "",
                LOCRegAvlBal: "",
                LOCClsCode: "",
                LOCHighAmt: "",
                LOCLowAmt: "",
                LOCAvg: "",
                LOCHighAmtDt: "",
                LOCLowAmtDt: "",
                LOCHighAmtLTD: "",
                LOCLowAmtLTD: "",
                LOCAvgLTD: "",
                LOCBankNetTot: "",
                LOCRedRvwFreq: 100,
                LOCRedRvwFreqUnits: "Months",
                LOCNxtRedDt: "2099-01-01",
                LOCRedPct: "",
                LOCSchedRedAmt: "0.01",
                LOCFeeArray: {
                    LnFeeInfoRec: {
                        LnFeeText: "",
                        LnFeeCode: "N",
                        LnFeeAmt: 0,
                        LnFeeAssmntDt: "",
                        LnFeeFreq: "",
                        LnFeeFreqUnits: "",
                        LnFeeDayOfMonth: "",
                        LnFeeChgCode: "",
                        LnFeeNxtPayDt: "",
                        LnFeeLastPmtDt: "",
                        LnFeeRemAmt: "",
                        LnFeeCaplze: "",
                        LnFeeId: "",
                        LnFeeStat: "",
                    }
                },
                LOCFeeAcctId: "",
                LOCFeeAcctType: "",
                LOCGdnceType: "N",
                LOCGdnceBorwAck: true,
                LOCGdnceRedType: "LOCAmt",
                LOCLastRedDt: "",
                UserDefInfoArray: {
                    UserDefInfo: {
                        UserDefTxt: "",
                        UserDefCode: "",
                        UserDefDesc: "",
                        UserDefDt: "",
                        UserDefInfo1: "",
                        UserDefInfo2: "",
                        UserDefInfo3: "",
                    }
                }
            }
        },
        conditioningData: {
            ErrOvrRds: [200594],
        }
    }
)