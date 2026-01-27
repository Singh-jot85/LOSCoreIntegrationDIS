. as $top | [ 
    { 
        first_time_borrower: ( if .customData | select("first_time_borrower") 
            then { 
                ventures_object:(.customData[] | select(.first_time_borrower) | .first_time_borrower.ventures_object),
                ventures_field:(.customData[] | select(.first_time_borrower) | .first_time_borrower.ventures_field), 
                value: .details.impact_data | (if .first_time_borrower== "yes" 
                    then "true" 
                    elif .first_time_borrower == "no"
                        then "false"
                    else empty
                    end
                ) 
            } 
        else empty 
        end ) 
    }, 
    { 
        first_time_business_owner:(if .customData | select("first_time_business_owner") 
            then {
                ventures_object:(.customData[] | select(.first_time_business_owner) | .first_time_business_owner.ventures_object),
                ventures_field:(.customData[] | select(.first_time_business_owner) | .first_time_business_owner.ventures_field), 
                value: .details.impact_data | (if .first_time_business_owner == "yes" 
                    then "true" 
                    elif .first_time_business_owner == "no"
                        then "false"
                    else empty
                    end
                )
            } 
        else empty 
        end)
    }, 
    {
        low_income_clients: (if .customData | select("low_income_clients") 
            then {
                ventures_object:(.customData[] | select(.low_income_clients) | .low_income_clients.ventures_object),
                ventures_field: (.customData[] | select(.low_income_clients) | .low_income_clients.ventures_field), 
                value: .details.impact_data | (if .low_income_clients == "yes" 
                    then "true" 
                    elif .low_income_clients == "no"
                        then "false"
                    else empty
                    end
                )
            } 
        else empty 
        end )
    }, 
    {
        percent_employees_paid_above_living_wage:(if .customData | select("percent_employees_paid_above_living_wage") 
            then {
                ventures_object:(.customData[] | select(.percent_employees_paid_above_living_wage) | .percent_employees_paid_above_living_wage.ventures_object),
                ventures_field:(.customData[] | select(.percent_employees_paid_above_living_wage) | .percent_employees_paid_above_living_wage.ventures_field), 
                value: .details.impact_data | ( if .percent_employees_paid_above_living_wage == null 
                    then empty 
                else ( .percent_employees_paid_above_living_wage | split("-") | map(tonumber) | add / length | tostring ) 
                end )
            } 
        else empty 
        end )
    }, 
    {
        living_wage:(if .customData | select("living_wage") then {
            ventures_object:(.customData[] | select(.living_wage) | .living_wage.ventures_object),
            ventures_field:(.customData[] | select(.living_wage) | .living_wage.ventures_field), 
            value:  .details.impact_data | ( if .living_wage == null 
                then empty 
                else (
                    .living_wage as $wage |
                    if ($wage and ($wage[0:1] == "$"))
                        then $wage[1:]
                    else $wage
                    end
                )
                end
            )
        } 
        else empty 
        end)
    }, 
    {
        free_reduced_prices:(if .customData | select("free_reduced_prices") 
            then {
                ventures_object:(.customData[] | select(.free_reduced_prices) | .free_reduced_prices.ventures_object),
                ventures_field:(.customData[] | select(.free_reduced_prices) | .free_reduced_prices.ventures_field), 
                value: .details.impact_data | (if .free_reduced_prices == "yes" 
                    then "true" 
                elif .free_reduced_prices == "no"
                    then "false"
                else empty
                end)
            } 
        else empty 
        end )
    }, 
    {
        projected_percent_of_low_income_clients:(if .customData | select("projected_percent_of_low_income_clients") 
            then {
                ventures_object:(.customData[] | select(.projected_percent_of_low_income_clients) | .projected_percent_of_low_income_clients.ventures_object),
                ventures_field:(.customData[] | select(.projected_percent_of_low_income_clients) | .projected_percent_of_low_income_clients.ventures_field), 
                value: .details.impact_data | (if .projected_percent_of_low_income_clients == null
                    then empty
                else .projected_percent_of_low_income_clients | split("-") | map(tonumber) | add / length | tostring 
                end )
            } 
        else empty 
        end )
    }, 
    {
        projected_clients_served:(if .customData | select("projected_clients_served")  
            then {
                ventures_object:(.customData[] | select(.projected_clients_served) | .projected_clients_served.ventures_object),
                ventures_field:(.customData[] | select(.projected_clients_served) | .projected_clients_served.ventures_field), 
                value: .details.impact_data | (if .projected_clients_served == null
                    then empty
                else .projected_clients_served | tostring 
                end )
            } 
            else empty 
            end
        )
    }, 
    {
        clients_currently_served:(if .customData | select("clients_currently_served")
            then {
                ventures_object:(.customData[] | select(.clients_currently_served) | .clients_currently_served.ventures_object),
                ventures_field:(.customData[] | select(.clients_currently_served) | .clients_currently_served.ventures_field), 
                value: .details.impact_data | (if .clients_currently_served == null
                    then empty
                else .clients_currently_served | tostring
                end )
            } 
            else empty 
            end
        )
    }, 
    {
        loan_sale_reviewed:(if .customData | select("loan_sale_reviewed") 
            then {
                ventures_object:(.customData[] | select(.loan_sale_reviewed) | .loan_sale_reviewed.ventures_object),
                ventures_field:(.customData[] | select(.loan_sale_reviewed) | .loan_sale_reviewed.ventures_field), 
                value: "false"
            } 
            else empty 
            end
        )
    }, 
    {
        lumos_credit_score:(if .customData | select("lumos_credit_score") 
            then {
                ventures_object:(.customData[] | select(.lumos_credit_score) | .lumos_credit_score.ventures_object),
                ventures_field:(.customData[] | select(.lumos_credit_score) | .lumos_credit_score.ventures_field), 
                value: $top.loan_interfaces[] | select(.interface_type == "lumos") | .details.lumos_response.results.lumosPrediction.lumos.score | tostring 
            } 
            else empty 
            end
        )
    }, 
    {
        lumos_credit_score_date:(if .customData | select("lumos_credit_score_date") 
            then {
                ventures_object:(.customData[] | select(.lumos_credit_score_date) | .lumos_credit_score_date.ventures_object),
                ventures_field:(.customData[] | select(.lumos_credit_score_date) | .lumos_credit_score_date.ventures_field), 
                value: $top.loan_interfaces[] | select(.interface_type == "lumos") | .details.lumos_response.metadata.applicationRunDate | split("T")[0] 
            } 
            else empty 
            end
        )
    },
    {
        loan_docs_to_borrower:(if .customData | select("loan_docs_to_borrower") 
            then {
                ventures_object:(.customData[] | select(.loan_docs_to_borrower) | .loan_docs_to_borrower.ventures_object),
                ventures_field:(.customData[] | select(.loan_docs_to_borrower) | .loan_docs_to_borrower.ventures_field), 
                value: (.closing_date)
            } 
            else empty 
            end 
        )
    },
    {
        lumos_expected_loss:(if .customData | select("lumos_expected_loss") 
            then {
                ventures_object:(.customData[] | select(.lumos_expected_loss) | .lumos_expected_loss.ventures_object),
                ventures_field:(.customData[] | select(.lumos_expected_loss) | .lumos_expected_loss.ventures_field), 
                value: $top.loan_interfaces[] | select(.interface_type == "lumos") | .details.lumos_response.results.lumosPrediction.lumos.expectedLoss | sub("%"; "") 
            } 
            else empty 
            end
        )
    } 
]