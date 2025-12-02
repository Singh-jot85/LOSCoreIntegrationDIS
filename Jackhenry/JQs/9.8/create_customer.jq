(
(
    . as $root |
    $root.loan_relations[0] |
    { 
        CustDetail: ( 
            {
                PersonName: {
                    ComName: (.full_name // null),
                    FirstName: (.first_name // null),
                    MiddleName: (.middle_name // null),
                    LastName:  (.last_name // null),
                    x_PersonName: {
                        NameSuffix: (.suffix // null),
                        LegalName: (.business_name // null)
                    }
                },
                Addr: (
                    .relation_addresses[] | 
                    select(.address_type == "permanent") |
                    {
                        StreetAddr1: (.address_line_1 // null),
                        StreetAddr2: (.address_line_2 // null),
                        City: (.city // null),
                        StateCode: (.state // null),
                        PostalCode: (.zip_code // null),
                        DlvryPt: (.zip_code_plus4 // null),
                    }
                ),
                CustType: (
                    if .party_type == "individual"
                        then "Y"
                    elif .party_type == "entity"
                        then "N"
                    else null
                    end
                ),
                NAICSCode: (.naics_code // null),
                BirthDt: (if .party_type == "individual" then .dob else null end),
                EmplName: ( .memberof // null),
                EmailArray: {
                    EmailInfo: {
                        EmailAddr: (.email // null)
                    }
                },
                PhoneArray: {
                    PhoneInfo: {
                        PhoneNum: (.work_phone | tostring // null),
                        PhoneExt: "+1",
                        PhoneType: (
                            if .party_type == "individual" 
                                then "Home Cell Phone"
                            elif .party_type == "entity" 
                                then "Business Phone"
                            else null 
                            end
                        )
                    }
                },
                CrScoreArray: {
                    CrScoreInfo: {
                        CrScoreId: ($root.fico_score // null),
                        CertCode: "C",
                        CertCodeDt: "2025-08-06"
                    }
                }
            }
        ),
        TaxDetail: (
            {
                TINInfo: {
                    TINCode: (
                        if .tin_type == "EIN" 
                            then "T" 
                        elif .tin_type == "SSN" 
                            then "I" 
                        else null 
                        end
                    ),
                    TaxId: (.tin // null),
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
                    else null
                    end
                ),
                NetWorth: (
                    if .details?.total_business_net_worth 
                        then .details?.total_business_net_worth
                    else null
                    end
                ),
                LangType: "English",
                NetWorthAmt: (
                    if .details?.total_business_net_worth 
                        then .details?.total_business_net_worth
                    else null
                    end
                )
            }
        ),
        RegDetail: (
            {
                CRARec: (
                    $root.geocoding_details[0] | 
                    {
                        CRAStateCode: ($root.details.cra_details?.state_code // null),
                        CRACountyCode: (.county_code // null),
                        CRACenTract: (.tract_code // null),
                        CRASMSACode: (.MSA_code // null),
                        CRALoc: (.address // null),
                        CRAIncmLvl: 1,
                    }
                ),
                ReqLegalEntityType: (
                    if .party_type == "individual"
                        then false
                    elif .party_type == "entity"
                        then true
                    else null
                    end
                ),
                BenflOwnExclCode: (
                    if .party_type == "individual"
                        then "NP"
                    else null
                    end
                ),
                AnnRevenueAmt: ($root.cra_gross_annual_revenue // null)
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