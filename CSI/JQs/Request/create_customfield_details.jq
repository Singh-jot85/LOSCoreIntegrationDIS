(
("50000") as $sub_account_number |
("LNS") as $application |
{
    loan_application_number: ((.loan_number) // ""),
    sub_account_number: $sub_account_number,
    application: $application,
    custom_fields: [(
        if (.product.product_code == "EL_TL" or .product.product_code == "EL_LOC") then {
            "ddn":"221001",
            "value":"SBL"
        },
        {
            "ddn":"221002",
            "value":"00"
        },
        {
            "ddn":"221003",
            "value":((.loan_interfaces[] | select(.interface_type == "sba-etran-originate-status" and .is_latest == true) | (if (.details.result.response.SBA_ETran_OrigStat_Response.LoanAppAppvDt and .details.result.response.SBA_ETran_OrigStat_Response.LoanAppAppvDt != "") then .details.result.response.SBA_ETran_OrigStat_Response.LoanAppAppvDt | split(" ")[0] | split("-") as $date | $date[0]+ $date[1] + $date[2] else null end)) // (.etran_authorization_date| split("T")[0] | split("-") as $etran_authorization_date | $etran_authorization_date[0]+$etran_authorization_date[1]+$etran_authorization_date[2]))
        } 
    else  {
        "ddn":"221001",
        "value":"SBL"
    },
    {
        "ddn":"221002",
        "value":"00"
    }
    end)
    ]
}
)