{ 
    CustId: .loan_relations[0].external_customer_id,
    RelAcctId: .loan_number,
    RelAcctType: "L",
    CustRelRec: { 
        AcctRelCode: (
            .loan_relations[0] |
            if (.relation_type == "guarantor")
                then "G"
            elif (.relation_type == "co_borrower")
                then "C"
            else null
            end 
        ), 
        CopyRelCustMail: "N" 
    } 
}