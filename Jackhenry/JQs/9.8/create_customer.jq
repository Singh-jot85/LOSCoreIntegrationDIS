(
(
    . as $root |
    $root.loan_relations[0] |
    { 
        CustDetail: ( 
            {
                PersonName: {
                    ComName: (.full_name // ""),
                    FirstName: (.first_name // ""),
                    MiddleName: (.middle_name // ""),
                    LastName:  (.last_name // ""),
                    x_PersonName: {
                        NameSuffix: (.suffix // ""),
                        LegalName: (.business_name // "")
                    }
                },
                Addr: (
                    .relation_addresses[] | 
                    select(.address_type == "permanent") |
                    {
                        StreetAddr1: (.address_line_1 // ""),
                        StreetAddr2: (.address_line_2 // ""),
                        City: (.city // ""),
                        StateCode: (.state // ""),
                        PostalCode: (.zip_code // ""),
                        DlvryPt: (.zip_code_plus4 // ""),
                    }
                ),
                CustType: (
                    if .party_type == "individual"
                        then "Y"
                    elif .party_type == "entity"
                        then "N"
                    else ""
                    end
                ),
                NAICSCode: (.naics_code // ""),
                BirthDt: (if .party_type == "individual" then .dob else "" end),
                EmplName: ( .memberof // ""),
                EmailArray: {
                    EmailInfo: {
                        EmailAddr: (
                        if .email != "" and .email != ""
                            then .email
                        elif (
                            .children != "" 
                            and (.children | length) > 0
                        )
                            then (
                                .children[] 
                                | select(.relation_type == "representative") as $representative
                                | if ($representative.email != "" and $representative.email != "")
                                    then $representative.email
                                else ""
                                end
                            )
                        else ""
                        end
                        )
                    }
                },
                PhoneArray: {
                    PhoneInfo: {
                        PhoneNum: (.work_phone | tostring // ""),
                        PhoneExt: "+1",
                        PhoneType: (
                            if .party_type == "individual" 
                                then "Home Cell Phone"
                            elif .party_type == "entity" 
                                then "Business Phone"
                            else "" 
                            end
                        )
                    }
                },
                CrScoreArray: {
                    CrScoreInfo: {
                        CrScoreId: ($root.fico_score // ""),
                        CertCode: "C",
                        CertCodeDt: (.created | split("T")[0] // "")
                    }
                }
            }
        ),
        TaxDetail: (
            {
                TINInfo: {
                    TINCode: (
                        if .party_type == "individual" 
                            then "T" 
                        elif .party_type == "entity" 
                            then "I" 
                        else "" 
                        end
                    ),
                    TaxId: (.tin // ""),
                    CertCode: "C",
                },
                Alien: {
                    CitzCntryType: "US"
                },
                FedWithCode: "0",
                StateWithCode: 0
            }
        ),
        BusDetail: (
            {
                OffCode: "BNO",
                BrCode: "51",
                CustCode: "Q",
                InsiderCode: (
                    if (
                        .party_type == "individual" 
                        and .entity_type != "sole_proprietor"
                    )
                        then "E"
                    else ""
                    end
                ),
                LangType: "English",
                NetWorthAmt: (
                    if .details?.total_business_net_worth 
                        then .details?.total_business_net_worth
                    else ""
                    end
                )
            }
        ),
        RegDetail: (
            {
                CRARec: (
                    $root.geocoding_details[0] | 
                    {
                        CRAStateCode: ($root.details.cra_details?.state_code // ""),
                        CRACountyCode: (.county_code // ""),
                        CRACenTract: (.tract_code // ""),
                        CRASMSACode: (.MSA_code // ""),
                        CRALoc: 1,
                        CRAIncmLvl: 1,
                    }
                ),
                ReqLegalEntityType: (
                    if .party_type == "individual"
                        then "false"
                    elif .party_type == "entity"
                        then "true"
                    else ""
                    end
                ),
                BenflOwnExclCode: (
                    if .party_type == "individual"
                        then "NP"
                    else ""
                    end
                ),
                AnnRevenueAmt: (
                    .details?.annual_revenue // ""
                )
            }
        ),
        conditioningData:{
            isSoleProp: (
                if (
                    .party_type == "individual" 
                    and .entity_type == "sole_proprietor" 
                    and .relation_type == "borrower"
                    and (.is_collateral_related | not) 
                ) then true
                else false
                end
            ),
            ErrOvrRds: [410023, 410050, 410059, 410079, 410017],
            entityType: (.entity_type // null),
            partyType: (.party_type // null)
        }
    }
)
)