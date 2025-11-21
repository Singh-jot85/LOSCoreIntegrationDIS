{ 
    CustId: (. as $root | $root.flat_relations | map(select(.id == $root.loan_relations[0].id))[0].parent_id as $pid | map(select(.id == $pid))[0].external_customer_id // ""),
    CustRelRec: { 
        IdVerifyBy: "Charles Barkley",
        IdVerifyRsnCode: "NEW",
        VerifyDt: "2024-02-28" 
    },
    BenflOwnInfo: { 
        CustId: .loan_relations[0].external_customer_id,
        PersonName: { 
            ComName: (if .loan_relations[0].party_type == "individual" then (.loan_relations[0].first_name + " " + .loan_relations[0].middle_name + " " + .loan_relations[0].last_name) else .loan_relations[0].business_name end) 
        },
        BenflOwnType: (if .loan_relations[0].is_ben_owner_by_control then (if .loan_relations[0].ownership_percentage then "CntlOwn" else "Cntl" end) else "Own" end),
        CntlIndivTitle: "Mr.",
        BenflOwnPct: (.loan_relations[0].ownership_percentage // 0),
        IdVerifyArray: [ 
            { IdVerifyCode: "FP",
            IdVerifyVal: "KD1234ffgt7845",
            IdVerifyBy: "RSS",
            IdIssueBy: "MO",
            IdVerifyQueryArray: [ 
                { 
                    IdVerifyQuery: "IssDt",
                    IdVerifyQueryVal: "2010-10-15" 
                },
                { 
                    IdVerifyQuery: "DocType",
                    IdVerifyQueryVal: "PHOTOCOPY" 
                } 
        } ] 
    } 
}