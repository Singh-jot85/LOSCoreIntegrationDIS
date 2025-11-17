(
({
   "other_cre": "CREO",
    "test": "CLCD",
    "office_flex": "CREF",
    "commercial_condominium": "COCD",
    "church": "CREW",
    "warehouse": "CHRC",
    "healthcare": "CREH", 
    "industrial": "CREI",
    "shopping_center": "CRES",
    "restaurant": "CRER", 
    "office": "CREB",
    "retail": "CRET"
}) as $creTypeMapping | 
{
    Input: {
        ExtensionRequests: null,
        Requests: ([
            {
                __type: "CollateralMaintenanceRequest:http://www.opensolutions.com/CoreApi",
                ParentRequestNumber: null,
                RequestNumber: null,
                PropertyList: ( 
                    if (. | has("loan_collateral"))
                        then .loan_collateral[0] | [
                            (
                                if .category == "machinery_and_equipment" 
                                    then {
                                        IsPropertyNew: false,
                                        PropertyTypeCode: "EQUP",
                                        PropertyTypeDetailCode: "NON",
                                        PropertyValue: (.collateral_value // null),
                                        PropertyDescription: (.description // null),
                                    }
                                elif .category == "residential_real_estate" 
                                    then {
                                        IsPropertyNew: false,
                                        PropertyTypeCode: (if .type == "multi_family_dwelling" then "MFPR" elif .type == "1_4_family_dwelling" then "14FR" else null end),
                                        PropertyTypeDetailCode: "RE1",
                                        LocationDescription: (.collateral_addresses[0] | .address_line_1 + " " + .address_line_2 + " " + .city),
                                        PropertyDescription: (.collateral_addresses[0] | .address_line_1 + " " + .address_line_2 + " " + .city),
                                        PropertyValue: (.collateral_value // null),
                                        PropertyId: (.conditions_data["REAL-ESTATE"].current_parcel_id),
                                        ParcelNumber: (.conditions_data["REAL-ESTATE"].current_parcel_id),
                                        OwnerOccupiedCode: (
                                            if .details.owner_occupied 
                                                then "OWN" 
                                            else "NOWN" 
                                            end
                                        ),
                                    } 
                                elif .category == "inventory_accounts_receivable" and .type == "all_accounts_receivable" 
                                    then {
                                        IsPropertyNew: false,
                                        PropertyTypeCode: "AR",
                                        PropertyTypeDetailCode: "NON",
                                        PropertyValue: (.collateral_value // null),
                                        PropertyDescription: (.description // null),
                                    } 
                                elif .category == "vehicles" 
                                    then {
                                        IsPropertyNew: false,
                                        PropertyTypeCode: (if .type == "motor_vehicle_new" then "AUTN" elif .type == "motor_vehicle_used" then "AUTU" elif .type == "ground_transportation_new" then "GRTN" elif .type == "ground_transportation_old" then "GRTU" else null end),
                                        PropertyId: (.details.vin // null),
                                        PlateStateCode: (.collateral_addresses[0].state // null),
                                        PropertyYearNumber: (.details.year // null),
                                        PropertyMake: (.details.make // null),
                                        PropertyModel: (.details.model // null),
                                        PropertyValue: (.collateral_value // null),
                                        PropertyDescription: (
                                            (.details.year | tostring) 
                                            + " "  + .details.make 
                                            + " " + .details.model 
                                            + " " + .details.vin
                                        )
                                    } 
                                elif .category == "all_business_assets" and .type == "all_assets" 
                                    then {
                                        IsPropertyNew: false,
                                        PropertyTypeCode: "ABSA",
                                        PropertyTypeDetailCode: "NON",
                                        PropertyValue: (.collateral_value // null),
                                        PropertyDescription: (.description // null),
                                    }
                                elif .category == "cash_and_equivalents" and .type == "deposit_account" 
                                    then {
                                        IsPropertyNew: false,
                                        PropertyTypeCode: "PSDA",
                                        PropertyTypeDetailCode: null,
                                        PropertyValue: (.collateral_value // null),
                                        PropertyDescription: (.description // null),
                                    } 
                                elif .category == "commercial_real_estate" 
                                    then {
                                        IsPropertyNew: false,
                                        PropertyTypeCode: ( $creTypeMapping[.type] // "CREO"),
                                        PropertyTypeDetailCode: "RE1",
                                        LocationDescription: (.collateral_addresses[0] | .address_line_1 + " " + .address_line_2 + " " + .city),
                                        PropertyDescription: (.collateral_addresses[0] | .address_line_1 + " " + .address_line_2 + " " + .city),
                                        PropertyId: (.conditions_data["REAL-ESTATE"].current_parcel_id),
                                        ParcelNumber: (.conditions_data["REAL-ESTATE"].current_parcel_id),
                                        PropertyValue: (.collateral_value // null),
                                        OwnerOccupiedCode: (if .details.owner_occupied then "OWN" else "NOWN" end),
                                    } 
                                elif .category == "land" 
                                    then {
                                        IsPropertyNew: false,
                                        PropertyTypeCode: (if .type == "land_for_development" then "CLCD" else null end),
                                        PropertyTypeDetailCode: "RE1",
                                        LocationDescription: (.collateral_addresses[0] | .address_line_1 + " " + .address_line_2 + " " + .city),
                                        PropertyDescription: (.collateral_addresses[0] | .address_line_1 + " " + .address_line_2 + " " + .city),
                                        PropertyId: (.conditions_data["REAL-ESTATE"].current_parcel_id),
                                        ParcelNumber: (.conditions_data["REAL-ESTATE"].current_parcel_id),
                                        PropertyValue: (.collateral_value // null),
                                        OwnerOccupiedCode: (if .details.owner_occupied then "OWN" else "NOWN" end),
                                    } 
                                else null 
                                end 
                            )
                        ]
                    else [
                        {
                            PropertyTypeCode: "UNSE",
                            PropertyTypeDetailCode: "UNS",
                            PropertyDescription: "Unsecured",
                        }
                    ]
                    end // []
                ),
            }
        ])
    },
    UserAuthentication: {},
    ShouldCommitOrRollback: false
}
)