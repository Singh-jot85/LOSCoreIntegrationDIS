def get_parent($pid; $flat_relations):
    if $pid != "" and $pid != null
        then $flat_relations[] | select(.id == $pid)
    else null
    end;

def get_parent_core_id($relation; $flat_relations):
    if $relation.parent_id != null
        then (
            get_parent($relation.parent_id; $flat_relations) as $parent |
            if $parent != null
                then (
                    if $parent.relation_type == "owner"
                        then get_parent_core_id($parent; $flat_relations)
                    elif $parent.relation_type == "borrower"
                        then $parent.external_customer_id
                    else ""
                    end
                )
            else ""
            end       
        )
    else ""
    end;

(
    . as $root |
    $root.loan_relations[0] | 
    {
        CustRelAdd:{
            CustId: (get_parent_core_id(. ; $root.flat_relations) // ""),
            CustRelRec: { 
                IdVerifyBy: ($root.loan_officer_name // null),
                IdVerifyRsnCode: "1",
                VerifyDt: (.created | split("T")[0] // "")
            },
            BenflOwnInfo:(            
                { 
                    CustId: .external_customer_id,
                    PersonName: { 
                        ComName: (.full_name // null)
                    },
                    BenflOwnType: (
                        get_parent(.parent_id ; $root.flat_relations) as $parent |
                        if $parent and $parent.relation_type == "owner"
                            then "OWN"
                        elif .is_ben_owner_by_control 
                            then (
                                if .ownership_percentage 
                                    then "CntlOwn" 
                                else "Cntl" 
                                end
                            ) 
                        else "Own"
                        end
                    ),
                    CntlIndivTitle: (
                        get_parent(.parent_id ; $root.flat_relations) as $parent |
                        if $parent and $parent.relation_type == "owner"
                            then ""
                        elif .is_ben_owner_by_control 
                            then (.position // "")
                        else ""
                        end
                    ),
                    BenflOwnPct: (.effective_ownership_percentage // 0),
                }
            )
        },
        conditioningData: {
            ErrOvrRds: [402066]
        }
    }
)