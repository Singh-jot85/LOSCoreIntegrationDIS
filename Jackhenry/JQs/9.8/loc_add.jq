(
    . as $root |
    {
        LOCAdd: {
            LOCAcctId: ($root.loan_number // null),
            LOCAcctType: "L",
            LOCCustId: (
                $root.loan_relations[]
                | select(.is_primary_borrower == true)
                | .external_customer_id // null
            ),
            LOCRec: {
                LOCAmt: ( .approved_amount // null ),
                LOCExpDt: ( .maturity_date // null),
                LOCCode: 1,
                LOCMainLOCId: null,
                LOCStat: 1,
                LOCBrCode: 51,
                LOCOffCode: (.boarding_details?.office_code // null),
                LOCPrtcpCode: null,
                LOCDDAProtAmt: null,
                LOCFrzAmt: null,
                LOCTaxRefId: null,
                LOCOrigTerm: (.term_in_months // null),
                LOCOrigTermUnit: "Months",
                LOCOrigAmt: 60000,
                LOCInfo: null,
                LOCPrtCnsldtStmt: "Y",
                LOCStmtDay: 1,
                LOCStmtFreq: 1,
                LOCStmtFreqCode: "M",
                LOCSemiDay1: null,
                LOCSemiDay2: null,
                LOCCallRptCode: "4A",
                LOCCollatCode: 14,
                LOCRiskCode: null,
                LOCLastStmtDt: null,
                LOCLastMainDt: null,
                LOCCurBal: 60000,
                LOCTotAdvaAmt: 60000,
                LOCAvlBal: 0,
                LOCCommBal: null,
                LOCRegAvlBal: null,
                LOCClsCode: null,
                LOCHighAmt: null,
                LOCLowAmt: null,
                LOCAvg: null,
                LOCHighAmtDt: null,
                LOCLowAmtDt: null,
                LOCHighAmtLTD: null,
                LOCLowAmtLTD: null,
                LOCAvgLTD: null,
                LOCBankNetTot: null,
                LOCRedRvwFreq: 100,
                LOCRedRvwFreqUnits: "Months",
                LOCNxtRedDt: "2099-01-01",
                LOCRedPct: null,
                LOCSchedRedAmt: "0.01",
                LOCFeeArray: {
                    LnFeeInfoRec: {
                        LnFeeText: null,
                        LnFeeCode: "N",
                        LnFeeAmt: 345,
                        LnFeeAssmntDt: "2025-11-18",
                        LnFeeFreq: 35,
                        LnFeeFreqUnits: 1,
                        LnFeeDayOfMonth: 10,
                        LnFeeChgCode: 3,
                        LnFeeNxtPayDt: null,
                        LnFeeLastPmtDt: null,
                        LnFeeRemAmt: 0,
                        LnFeeCaplze: 54,
                        LnFeeId: 345,
                        LnFeeStat: null,
                    }
                },
                LOCFeeAcctId: 0,
                LOCFeeAcctType: null,
                LOCGdnceType: null,
                LOCGdnceBorwAck: null,
                LOCGdnceRedType: null,
                LOCLastRedDt: null,
                UserDefInfoArray: {
                    UserDefInfo: {
                        UserDefTxt: null,
                        UserDefCode: null,
                        UserDefDesc: null,
                        UserDefDt: null,
                        UserDefInfo1: null,
                        UserDefInfo2: null,
                        UserDefInfo3: null,
                    }
                }
            }
        },
        conditioningData: {
            ErrOvrRds: [200594],
        }
    }
)