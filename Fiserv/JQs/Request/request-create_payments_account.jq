(
    ("1753106520000") as $currentDateTime | 
{
    Input: {
        Requests: [
            {
                __type: "RepetitiveTransferMaintenanceRequest:http://www.opensolutions.com/CoreApi",
                RequestNumber: "1",
                AllotmentRequests: [
                    {
                        ACHReceivingAccountTypeCode: "LN",
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
                        DueDayNumber: null, #01
                        EffectiveDate: "/Date(\($currentDateTime))/",
                        InitialDueDate: (
                            if (.loan_approval.approved_first_payment_date)
                                then (.loan_approval.approved_first_payment_date 
                                    | (.+ "T00:00:00Z" | fromdateiso8601 * 1000) 
                                    | "/Date(\(.))/"
                                )
                            else null
                            end
                        ),
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
                        IsACHOriginated: (
                            if (.bank_details.is_internal_account != null)
                                then (.bank_details.is_internal_account | not)
                            else null
                            end
                        ),
                        ACHOriginatedOrganizationNumber: 1,
                        ExternalAccountName: ( .loan_relations[] | select(.is_primary_borrower==true) | .full_name),
                        ReceivingRouteNumber: (.bank_details.routing_number // null),
                        ExternalAccountNumber: (.bank_details.account_number // null),
                        AccountNumber: (.loan_number // null),
                        EndDate: null, #"/Date(1910623380000)/"
                        ReceivingPersonNumber: null, #"920933"
                    }
                ]
            }
        ]
    }    
}
)