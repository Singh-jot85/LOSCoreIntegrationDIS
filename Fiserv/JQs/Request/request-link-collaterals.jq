(
{
    Input: {
        ExtensionRequests: null,
        Requests: [
            {
                __type: "CollateralMaintenanceRequest:http://www.opensolutions.com/CoreApi",
                ParentRequestNumber: null,
                RequestNumber: null,
                PropertyList: ( . as $root |
                    if ( $root | has("loan_collateral"))
                        then( $root.loan_collateral[0] | [
                            {
                                CollateralMargin: (
                                    (
                                        {
                                            AcceptDate: "/Date(\(now*1000 | floor))/",
                                            EffectiveDate: "/Date(\(now*1000 | floor))/",
                                            AccountNumber: ($root.loan_number // null),
                                        }
                                    ) + 
                                    (
                                        if ( .category | IN("residential_real_estate", "commercial_real_estate", "land") )
                                            then { 
                                                MarginPercent: ( .details.collateral_margin | tonumber? / 100 ) 
                                            }
                                        else {}
                                        end
                                    )
                                ),
                                PropertyNumber: (
                                    if (.details | has("core_integration_create_collaterals"))
                                        then (
                                            .details.core_integration_create_collaterals
                                            | .responses[0]?.collateralId? // null
                                        )
                                    else null
                                    end
                                )
                            }
                        ])
                    else {
                        CollateralMargin:{
                            AcceptDate: "/Date(\(now*1000 | floor))/",
                            EffectiveDate: "/Date(\(now*1000 | floor))/",
                            AccountNumber: ($root.loan_number // null),
                        },
                        PropertyNumber: (
                            if ($root.details | has("core_integration_create_collaterals"))
                                then (
                                    $root.details.core_integration_create_collaterals
                                    | .responses[0]?.collateralId? // null
                                )
                            else null
                            end
                        )
                    }
                    end 
                )
            }
        ],
        UserAuthentication: {}
    },
    ShouldCommitOrRollback: false
}
)