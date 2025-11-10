(
({
    "Working Capital": "WKCP",
    "Leasehold Improvement": "LSIM",
    "Purchase Equipment": "PUEQ",
    "Purchase Transport Equip": "PUTE",
    "Purchase Other Capital Assets": "PUCA",
    "Purchase Com'l RE": "PUCR",
    "Other": "OTHR",
    "Debt Consolidation": "DEBT",
    "Debt Refinance": "DEBT"
}) as $purposeCode | 
([
    "other_cre",
    "office_flex",
    "commercial_condominium",
    "church",
    "warehouse",
    "healthcare",
    "industrial",
    "shopping_center",
    "restaurant",
    "office",
    "retail"
]) as $creTypes |
([
    "machinery_and_equipment",
    "cash_and_equivalents"  
]) as $equipmentCategoryTypes |

def first_of_next_month_date:
  (now | strftime("%Y-%m-01") | strptime("%Y-%m-%d") | mktime) 
  + (32*24*60*60)
  | strftime("%Y-%m-01")
  | strptime("%Y-%m-%d") | mktime
  | (.*1000 | floor | tostring)
  | "/Date(" + . + ")/";

def get_NCUACategoryCode($collateral; $creTypes):
    ({
        "first": "1TDF",
        "second": "2TDF"
    }) as $positionMapping | 
    # Define SEC-producing combinations
    ([
        {"category": "all_business_assets", "type": "all_assets"},
        {"category": "cash_and_equivalents", "type": "deposit_account"},
        {"category": "machinery_and_equipment"},
        {"category": "inventory_accounts_receivable", "type": "all_accounts_receivable"}
    ]) as $secPairs |
    (
        if (INDEX($secPairs[]; 
            select(
                .category == $collateral.category 
                and ((has("type") | not) or (.type == $collateral.type))
            ))
        ) 
            then "SEC"
        elif $collateral.category == "residential_real_estate" 
            then (
                if $collateral.type == "multi_family_dwelling" or $collateral.type == "1_4_family_dwelling" 
                    then $positionMapping[$collateral.lien_position] // null
                else null 
                end 
            )
        elif $collateral.category == "vehicles" 
            then  (
                if $collateral.type == "motor_vehicle_new" or $collateral.type == "ground_transportation_new" 
                    then "NEWV" 
                elif $collateral.type == "motor_vehicle_used" or $collateral.type == "ground_transportation_old" 
                    then "USDV" 
                else null 
                end
            )
        elif $collateral.category == "land" and $collateral.type == "land_for_development" 
            then $positionMapping[$collateral.lien_position] // null
        elif $collateral.category == "commercial_real_estate" 
            then (
                if ($collateral.type | IN($creTypes))
                    then $positionMapping[$collateral.lien_position] // null
                else null 
                end
            )
        else null 
        end 
    );
{
    Input: {
        Requests: [
            {
                __type: "AccountMaintenanceRequest:http://www.opensolutions.com/CoreApi",
                Accounts: [ 
                    {
                        AccountNumber: (.loan_number // null),
                        IsAccountMaintenance: false,
                        MajorAccountTypeCode: "CML",
                        CurrentMinorAccountTypeCode: (
                            if .product.product_code == "SB_LOC" 
                                then "BRLV" 
                            elif .product.product_code == "SB_TL" 
                                then "BTFX" 
                            else null 
                            end
                        ),
                        BankOrganizationNumber: 1,
                        PaymentAmount: (if .product.product_code == "SB_LOC" then null elif .product.product_code == "SB_TL" then ((.loan_interfaces[] | select(.interface_type == "sherman" and .is_latest == true) | (.details.outLOAN_BUILDER.PmtStream // .details.outEQUAL_PMT.PmtStream) | if type == "object" then .Pmt elif type == "array" then .[0].Pmt else null end) | tonumber // null) else null end),
                        BranchOrganizationNumber: (.details.boarding_details.branch_code // 51),
                        CalculationScheduleEffectiveDate: "/Date(\(now*1000 | floor))/",
                        OwnershipCode: (
                            if ([.loan_relations[] | select(.relation_type == "borrower")] | length) == 1 
                                then "S" 
                            else "JA" 
                            end
                        ),
                        NCUACategoryCode: ( 
                            [ .collaterals[] ] as $collateralList 
                            | [$collateralList[] | select(.type | IN($creTypes[])) ] as $CRECollateralList
                            | [$collateralList[] | select(.category == "vehicles") ] as $AUTOCollateralList
                            | [$collateralList[] | select(.category | IN($equipmentCategoryTypes[])) ] as $equipmentCollateralList
                            | (
                                if ( $collateralList | type == "array" and length == 0 )
                                    then "USEC"
                                elif $CRECollateralList | length > 0
                                    then get_NCUACategoryCode($CRECollateralList[0]; $creTypes)
                                elif $AUTOCollateralList | length > 0
                                    then get_NCUACategoryCode($AUTOCollateralList[0]; $creTypes)
                                elif $equipmentCollateralList | length > 0
                                    then get_NCUACategoryCode($equipmentCollateralList[0]; $creTypes)
                                else get_NCUACategoryCode($collateralList[0]; $creTypes)
                                end
                            )
                        ),
                        CurrentAccountStatusCode: "ACT",
                        DateMaturity: (
                            if (
                                .product.product_code == "SB_LOC" 
                                or .product.product_code == "SB_TL"
                            )
                                then ( .maturity_date | 
                                    if . == null or . == "" 
                                        then null 
                                    else (strptime("%Y-%m-%d") | mktime * 1000 | "/Date(\(.))/" )
                                    end
                                ) 
                            else null 
                            end
                        ), 
                        NextDueDate: (.loan_approval.approved_first_payment_date | 
                            if (. == null or . == "") 
                                then null 
                            else strptime("%Y-%m-%d") | mktime * 1000 | "/Date(\(.))/" 
                            end
                        ),
                        PaymentCalendarPeriodCode: "MNTH",
                        OriginalBalance: (.disbursements | ( 
                            if type == "array" 
                                then .[0] 
                            elif type == "object" 
                                then . 
                            else null 
                            end ) | .disbursement_amount // null
                        ),
                        OriginalTerm: (.loan_approval.approved_term // null),
                        IsShareStatement: true,
                        IsUseProductDefaultDeliveryMethod: true,
                        ContractDate: (.closing_date | 
                            if . == null or . == "" 
                                then null 
                            else strptime("%Y-%m-%d") | mktime * 1000 | "/Date(\(.))/" 
                            end
                        ),
                        InterestRate: (.loan_approval.approved_rate/100 // null),
                        AccountRiskRating: {
                            AccountRiskRatingEffectiveDate: (.underwriter_decision_date | 
                                if . == null or . == "" 
                                    then null 
                                else strptime("%Y-%m-%d") | mktime * 1000 | "/Date(\(.))/" 
                                end
                            ),
                            AccountRiskRatingCode: "003B"
                        },
                        AccountUserFields: [ {
                            UserFieldCode: "LCOP",
                            UserFieldValue: (.application_number // null)
                        } ],
                        AccountRoles: ( 
                            ( (
                                if (.loan_relations[] | select(.is_primary_borrower == true) | .entity_type == "sole_proprietor" )
                                    then [
                                        {
                                            AccountRoleCode: "GUAR",
                                            AccountRoleValue: (.loan_relations[] | select(.is_primary_borrower == true) | .external_customer_id as $cif | .details.core_integration_response.customer_details[$cif].customer_details.org_cif | tostring // null),
                                            EntityTypeCode: "ORG",
                                            IsRemove: null,
                                            LiabilityAmount: null,
                                            LiabilityPercent: null
                                        },
                                        {
                                            AccountRoleCode: "SIGN",
                                            AccountRoleValue: (.loan_relations[] | select(.is_primary_borrower == true) | .external_customer_id // null),
                                            EntityTypeCode: "PERS",
                                            IsRemove: null,
                                            LiabilityAmount: null,
                                            LiabilityPercent: null
                                        } 
                                    ] 
                                else [ .flat_relations[] | select(.external_customer_id != null) ] 
                                    # | unique_by(.external_customer_id) 
                                    | map(
                                        {
                                            AccountRoleCode: ( 
                                                if .relation_type == "borrower" 
                                                    then "GUAR" 
                                                elif .relation_type == "guarantor"
                                                    then "GUAR" 
                                                elif .relation_type == "owner" 
                                                    then "SIGN" 
                                                else null 
                                                end
                                            ),
                                            AccountRoleValue: (.external_customer_id // null),
                                            EntityTypeCode: (
                                                if .party_type == "individual" 
                                                    then "PERS" 
                                                else "ORG" 
                                                end
                                            ),
                                            IsRemove: null,
                                            LiabilityAmount: null,
                                            LiabilityPercent: null
                                        }
                                    )
                                end ) 
                            ) + 
                            ( 
                                .details.boarding_details | to_entries
                                | map(
                                    select(
                                        ( .key | IN("acto","loff","oemp") )
                                        and .value != null 
                                        and .value != "" 
                                    )
                                )
                                | map(
                                    {
                                        AccountRoleCode: (.key | ascii_upcase),
                                        AccountRoleValue: (
                                            if .value 
                                                then (.value | tonumber)
                                            else null
                                            end
                                        ),
                                        EntityTypeCode: "PERS",
                                        IsRemove: null,
                                        LiabilityAmount: null,
                                        LiabilityPercent: null
                                    }
                                )
                            ) 
                        ),
                        Organizations: [{
                            IsTaxReportedForOwner: true,
                            IsTaxReportedForSigner: true,
                            OrganizationNumber: ((.loan_relations[] | select(.is_primary_borrower == true) | .external_customer_id) // null),
                            AccountRoles: [{
                                AccountRoleCode: "GUAR"
                            }],
                            CreditScores: {
                                CreditScore: (.loan_interfaces[] | select(.interface_type == "lumos") | .details.lumos_response.results.lumosPrediction.lumos.score // null),
                                ScoreDate: (((.loan_interfaces[] | select(.interface_type == "lumos") | .details.lumos_response.metadata.applicationRunDate // null) | if . == null or . == "" then null else split("T")[0] | strptime("%Y-%m-%d") | mktime * 1000 | "/Date(\(.))/" end) // null)
                            }
                        }],
                        AccountLoanDetail: {                            
                            AccountLoanInformation: {
                                LoanSourceCode: "LCOP",
                                IsLoanLimit: (if .product.product_code == "SB_LOC" then true elif .product.product_code == "SB_TL" then false else null end),
                                CRACategoryCode: (.cra_loan_type // null), 
                                CreditReportTypeCode: "EXCL",
                                CreditScore: (.fico_score | tostring // null),
                                Date1stPmtDue: (.loan_approval.approved_first_payment_date | if . == null or . == "" then null else strptime("%Y-%m-%d") | mktime * 1000 | "/Date(\(.))/" end), 
                                EstMaturityDate: (if .product.product_code == "SB_TL" then null elif .product.product_code == "SB_LOC" then (.maturity_date | if . == null or . == "" then null else strptime("%Y-%m-%d") | mktime * 1000 | "/Date(\(.))/" end) else null end),
                                LineOfCreditCloseDate: null,
                                GraceDays: "10",
                                IsBalloonLoan: false,
                                IsBillingLeadDaysOverrideNull: false,
                                IsDemandLoan: false,
                                IsLateFeeCalculationVariablesToAccountLevel: true,
                                IsNonRESPA: null,
                                IsNotRealEstate: false,
                                IsPrinSurplusProc: false,
                                IsRateChangeReCalulatedPayment: (if .product.product_code == "SB_LOC" then true elif .product.product_code == "SB_TL" then false else null end),
                                IsRepricingPlanAllowed: false,
                                IsRestructured: null,
                                IsRevolveLoan: (if .product.product_code == "SB_LOC" then true elif .product.product_code == "SB_TL" then false else null end),
                                LoanLossCategoryCode: "COMM",
                                LoanQualityCode: null,
                                MultiDueDates: null,
                                NextPaymentChangeDate: null,
                                OTSLoanCategoryCode: null,
                                OddDaysInterestDue: null,
                                OrignalLTVRatio: (if .approved_amount then .approved_amount / .total_collateral_value_v2 else null end),
                                PaymentDueDayNumber: "1",
                                PaymentMethodCode: "BILL",
                                PmtChangeLeadDays: null,
                                PurposeCode: (
                                    if $purposeCode[.loan_purpose] 
                                        then $purposeCode[.loan_purpose] 
                                    else "OTHR" 
                                    end
                                ),
                                RateChangeLeadDays: null,
                                RefinancedPriorAccountNumber: null,
                                RiskRatingCode: "003B",
                                UpdateWhenNull: null
                            },
                            AccountLoanLimitHistory: {
                                CreditLimitAmount: (
                                    if .product.product_code == "SB_LOC" 
                                        then (.loan_approval.approved_amount // null) 
                                    else null end
                                ),
                                EffectiveDate: "/Date(\(now*1000 | floor))/",
                                InactiveDate: (if .product.product_code == "SB_LOC" then (.maturity_date | if . == null or . == "" then null else strptime("%Y-%m-%d") | mktime * 1000 | "/Date(\(.))/" end) else null end)
                            },
                            AccountHolds: (if any(.loan_relations[]?.collaterals[]?; 
                                .category == "cash_and_equivalents" and .type == "deposit_account") 
                                then 
                                .loan_relations[] 
                                | .collaterals[] 
                                | select(.category == "cash_and_equivalents" and .type == "deposit_account") 
                                else 
                                null 
                                end) | {
                                AccountHoldCode: (if . == null then null else "COLH" end), 
                                DepositAccountNumber: (if . == null then null else .details.account_number end), 
                                HoldAmount: (if . == null then null else .details.pledged_amount end), 
                                },
                            AccountReviewHistory: {
                                ReviewDate: (if .product.product_code == "SB_TL" then "/Date(\((now + 31536000)*1000 | floor))/" else null end)
                            },
                            AccountInterestHistoryInformations: [
                                {
                                    AmortizationTerm: (.loan_approval.approved_term * 30.4375 // null) | round,
                                    BalanceCategoryCode: "NOTE",
                                    CalculationScheduleNumber: (if .product.product_code == "SB_LOC" then 3 elif .product.product_code == "SB_TL" then 4 else null end),
                                    DaysMethodCode: "ACT",
                                    EffectiveDate: "/Date(\(now*1000 | floor))/",
                                    InterestBase: "360",
                                    InterestMethodCode: "SMP",
                                    IsCapitalizeInterest: false,
                                    IsNegativeAmortizationAllowed: false,
                                    MarginFixed: (if .differential_rate then (.differential_rate/100 | tostring) else null end),
                                    MaximumInterestRate: (.max_rate/100 // null),
                                    MinimumInterestRate: ( .loan_approval.approved_rate/100 // null ),
                                    NextRateChangeDate: (
                                        if .product.product_code == "SB_LOC" 
                                            then first_of_next_month_date
                                        else null 
                                        end
                                    ),
                                    PaymentChangeCalenderPeriodCode: (if .product.product_code == "SB_LOC" then "MNTH" else null end), 
                                    RateChangeCalendarPeriodCode: (if .product.product_code == "SB_LOC" then "MNTH" else null end), 
                                    RateChangeMethodCode: (if .product.product_code == "SB_LOC" then "CALP" else null end),
                                    RateTypeCode: (if .product.product_code == "SB_LOC" then "VAR" elif .product.product_code == "SB_TL" then "FIX" else null end)
                                }
                            ],
                            AccountPaymentHistoryInformation: {
                                IsMajorMinorOverride: false,
                                PaymentBalanceCategoryCode: "NOTE",
                                PaymentBalanceTypeCode: (if .product.product_code == "SB_LOC" then "INT" elif .product.product_code == "SB_TL" then "DUE" else null end),
                                PaymentCalendarPeriodCode: "MNTH",
                                PaymentDueDayNumber: "1",
                                PaymentTypeCode: (if .product.product_code == "SB_LOC" then "VINT" elif .product.product_code == "SB_TL" then "FDUE" else null end)
                            }
                        }
                    }
                ]
            } 
        ],
        UserAuthentication: {}
    }
}
)