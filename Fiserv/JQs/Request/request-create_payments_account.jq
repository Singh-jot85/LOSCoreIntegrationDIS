(
({
    "checking": "CK",
    "saving": "SAV"
}) as $ACHAccTypeMapping |
{
    Input: {
        Requests: [
            {
                __type: "RepetitiveTransferMaintenanceRequest:http://www.opensolutions.com/CoreApi",
                RequestNumber: "1",
                AllotmentRequests: [
                    {
                        ACHReceivingAccountTypeCode: ($ACHAccTypeMapping[.bank_details.account_type] // null),
                        ACHReceivingTypeCode: "ORG",
                        BalanceCategoryCode: "NOTE",
                        BalanceTypeCode: "BAL",
                        RtxnTypeCode: "XWTH",
                        AllotmentTypeCode: (
                            if (.product.product_code == "SB_LOC")
                                then "LPMT"
                            elif (.product.product_code == "SB_TL")
                                then "SCHD"
                            else null end 
                        // null),
                        CalenderPeriodCode: "MNTH",
                        FundTypeCode: "EL",
                        DueDayNumber: 1,
                        EffectiveDate: "/Date(\(now*1000 | floor))/",
                        NextDisbursementDate: (
                            if (.loan_approval.approved_first_payment_date)
                                then (.loan_approval.approved_first_payment_date 
                                    | (.+ "T00:00:00Z" | fromdateiso8601 * 1000) 
                                    | "/Date(\(.))/"
                                )
                            else null
                            end
                        ),
                        FixedAmount: (
                            if (.product.product_type.product_type_code == "LOC")
                                then null
                            elif (.product.product_code == "SB_TL")
                                then( .loan_interfaces[] | select(.interface_type=="sherman" and .is_latest==true) 
                                    | if (
                                        .details.outLOAN_BUILDER
                                        and .details.outLOAN_BUILDER.AmTable
                                        and .details.outLOAN_BUILDER.AmTable.AmLine
                                    )
                                        then .details.outLOAN_BUILDER.AmTable.AmLine[] | select(.Idx=="1") | .Pmt
                                    else null
                                    end
                                )
                            else null
                            end
                        ),
                        GraceDays: 0,
                        IsACHOriginated: (.bank_details?.is_internal_account // null),
                        ACHOriginatedOrganizationNumber: 1,
                        ExternalAccountName: ( 
                            if .bank_details.is_internal_account == false
                                then .loan_relations[] | select(.is_primary_borrower==true) | .full_name
                            else null
                            end
                        ),
                        ReceivingRouteNumber: (
                            if .bank_details.is_internal_account == false
                                then .bank_details.routing_number // null
                            else null
                            end
                        ),
                        ExternalAccountNumber: (
                            if .bank_details.is_internal_account == false
                                then .bank_details.account_number // null
                            else null
                            end
                        ),
                        AccountNumber: (.loan_number // null),
                        EndDate: null,
                        ReceivingPersonNumber: null,
                        IsFutureReceivable: false,
                        AllotmentDescription: (
                            .bank_details?.account_number as $accNum
                            | "Commercial loan payment \($accNum)"
                        ),
                        AdditionalDescription: (
                            .bank_details?.account_number as $accNum
                            | "SECU Loan Payment \($accNum)"
                        ),
                        ReceivingInternalAccountNumber: (
                            if .bank_details.is_internal_account == true
                                then .bank_details.account_number
                            else null
                            end
                        )
                    }
                ]
            }
        ]
    }    
}
)