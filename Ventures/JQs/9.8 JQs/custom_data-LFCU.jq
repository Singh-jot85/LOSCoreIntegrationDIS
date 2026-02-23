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
        call_report_code:(if .customData | select("call_report_code") 
            then {
                ventures_object:(.customData[] | select(.call_report_code) | .call_report_code.ventures_object),
                ventures_field:(.customData[] | select(.call_report_code) | .call_report_code.ventures_field), 
                value:(if $callreportcode[.call_code] then $callreportcode[.call_code] else .call_code end) ,
            } 
        else empty 
        end )
    }, 
    {
        loc_amount:(if .customData | select("loc_amount") 
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
    }
]
)