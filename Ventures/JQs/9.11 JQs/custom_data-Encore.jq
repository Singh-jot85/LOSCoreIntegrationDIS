(
    ({
        "703A": "1C2A - 1-4 family residential properties - first liens",
        "386A": "1C2B - 1-4 family residential properties - junior liens",
        "400M": "1D - Secured by multifamily (5 or more) residential properties",
        "143B3": "1A2 - Construction land development and other land loans",
        "400J2": "1E2 - Secured by other nonfarm nonresidential properties",
        "400J3": "1E2 - Secured by other nonfarm nonresidential properties",
        "042A5": "1B - Secured by farmland",
        "400H2": "1E1 - Secured by owner-occupied nonfarm non-residential properties",
        "718A5": "1E2 - Secured by other nonfarm nonresidential properties",
        "400P": "4A - Commercial and industrial loans - US addresses",
        "400L2": "4A - Commercial and industrial loans - US addresses",
        "LN0051": "6D - Other consumer loans (includes single payment installment and all student loans) (or 4A - Commercial and industrial loans - US addresses if business purpose)",
        "LN0057": "4A - Commercial and industrial loans - US addresses",
        "LN0054": "6D - Other consumer loans (includes single payment installment and all student loans) (or 4A - Commercial and industrial loans - US addresses if business purpose)",
        "691P1": "4A - Commercial and industrial loans - US addresses",
        "691C1": "4A - Commercial and industrial loans - US addresses",
        "385": "6C - Loans to individuals - automobile loans",
        "370": "6C - Loans to individuals - automobile loans",
        "386B": "9B2 - All other loans (exclude consumer loans)",
        "698C": "9B2 - All other loans (exclude consumer loans)",
        "397": "9B2 - All other loans (exclude consumer loans)",
        "042A6": "3 - Loans to finance agricultural production",
        "400M1": "1D - Secured by multifamily (5 or more) residential properties",
        "400H3": "1E1 - Secured by owner-occupied nonfarm non-residential properties",
        "400L3": "4A - Commercial and industrial loans - US addresses",
        "954": "10B - All other leases",
        "960B": "9B2 - All other loans (exclude consumer loans)",
        "779A": "8 - Obligations",
        "1a1": "1A1 - 1-4 family residential construction loans",
        "1a2": "1A2 - Construction land development and other land loans",
        "1b": "1B - Secured by farmland",
        "1c": "1C1 - Revolving open-end loans secured by 1-4 family residential properties",
        "1c1": "1C1 - Revolving open-end loans secured by 1-4 family residential properties",
        "1c2": "1C2A - 1-4 family residential properties - first liens",
        "1c2a": "1C2A - 1-4 family residential properties - first liens",
        "1c2b": "1C2B - 1-4 family residential properties - junior liens",
        "1d": "1D - Secured by multifamily (5 or more) residential properties",
        "1e": "1E1 - Secured by owner-occupied nonfarm non-residential properties",
        "3": "3 - Loans to finance agricultural production",
        "4": "4A - Commercial and industrial loans - US addresses",
        "4a": "4A - Commercial and industrial loans - US addresses",
        "6c": "6C - Loans to individuals - automobile loans",
        "4A": "4A - Commercial and industrial loans - US addresses"
    }) as $callreportcode |
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
                else .living_wage | tostring | gsub("^[\\$]";"")
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
        projected_percent_of_low_income_clients:(if .customData | select("projected_percent_of_low_income_clients") and ($top.loan_relations[] | select(.is_primary_borrower == true) | .details.projected_percent_of_low_income_clients) 
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
        projected_clients_served:(if .customData | select("projected_clients_served") and ($top.loan_relations[] | select(.is_primary_borrower == true) | .details.projected_clients_served) 
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
        clients_currently_served:(if .customData | select("clients_currently_served") and ($top.loan_relations[] | select(.is_primary_borrower == true) | .details.clients_currently_served) 
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
        loc_amount:(
            if .customData | select("loc_amount") 
                then {
                    ventures_object:(.customData[] | select(.loc_amount) | .loc_amount.ventures_object),
                    ventures_field:(.customData[] | select(.loc_amount) | .loc_amount.ventures_field), 
                    value:(
                        if (.product.product_code | IN("SB_LOC","EL_LOC"))
                            then .approved_amount | tostring 
                        else empty
                        end 
                    )
                } 
            else empty 
            end 
        )
    }, 
    {
        call_report_code:(
            if .customData | select("call_report_code") 
                then {
                    ventures_object:(.customData[] | select(.call_report_code) | .call_report_code.ventures_object),
                    ventures_field:(.customData[] | select(.call_report_code) | .call_report_code.ventures_field), 
                    value:(if $callreportcode[.call_code] then $callreportcode[.call_code] else .call_code end) ,
                } 
                else empty 
                end 
            )
    }, 
    {
        loan_docs_to_borrower:(
            if .customData | select("loan_docs_to_borrower") 
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
)