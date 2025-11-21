(
    . as $root |
    { 
        CustId: ( 
            $root.flat_relations | 
            map(select(.id == $root.id))[0].parent_id as $pid | 
            map(select(.id == $pid))[0].external_customer_id // ""
        ),
        CustRelRec: { 
            IdVerifyBy: ($root.loan_officer_name // null),
            IdVerifyRsnCode: "NEW",
            VerifyDt: "2024-02-28" 
        },
        BenflOwnInfo:( 
            $root.loan_relations[0] | 
            { 
                CustId: .external_customer_id,
                PersonName: { 
                    ComName: (.full_name // null)
                },
                BenflOwnType: (
                    if .is_ben_owner_by_control 
                        then (
                            if .ownership_percentage 
                                then "CntlOwn" 
                            else "Cntl" 
                            end
                        ) 
                    else "Own"
                    end
                ),
                CntlIndivTitle: ( .title // null),
                BenflOwnPct: ( .ownership_percentage // 0),
            }
        )
    }
)