from los.configurations.models import Configuration, OrganizationConfiguration

interfaces = {
    "ci-ventures-entity-mapping":{
        "method_config": [
            {
                "document_type": {
                    "method": "fetch_configuration_data",
                    "flavour": "DocumentType"
                }
            },
            {
                "custom_object": {
                    "method": "fetch_configuration_data",
                    "flavour": "CustomObject"
                }
            },
            {
                "custom_field": {
                    "method": "fetch_configuration_data",
                    "flavour": "CustomField"
                }
            },
            {
                "uop_purpose_types": {
                    "method": "fetch_configuration_data",
                    "flavour": "UseOfProceedType"
                }
            },
            {
                "collateral_types": {
                    "method": "fetch_configuration_data",
                    "flavour": "CollateralType"
                }
            }
        ],
        "relation_types": [
            "borrower",
            "co_borrower",
            "owner"
        ],
        "create_customer": {
            "method_name": {
                "entity": "execute_create_company_request",
                "individual": "execute_create_contact_request"
            },
            "get_tranformed_config": {
                "entity": "create_company",
                "individual": "create_contact"
            }
        },
        "create_loan_customer":{
            "method_name": {
                "entity": "execute_create_loan_company_request",
                "individual": "execute_create_loan_contact_request" 
            },
            "get_tranformed_config": {
                "entity": "create_loan_company",
                "individual": "create_loan_contact"
            }
        },
        "update_loan_customer":{
            "method_name": {
                "entity": "execute_update_loan_company_request",
                "individual": "execute_update_loan_contact_request"
            },
            "get_tranformed_config": {
                "entity": "update_loan_company",
                "individual": "update_loan_contact"
            }
        },
        "delete_loan_customer": {
            "method_name": {
                "entity": "execute_delete_loan_company_request",
                "individual": "execute_delete_loan_contact_request"
            },
            "get_tranformed_config": {
                "entity": "delete_loan_company",
                "individual": "delete_loan_contact"
            }
        },
        "search_accounts": {},
        "search_customers": {
            "method_name": {
                "entity": "execute_search_company_request",
                "individual": "execute_search_contact_request"
            },
            "get_tranformed_config": {
                "entity": "search_company",
                "individual": "search_contact"
            }
        },
        "list_objects": {
            "method_name": {
                "collaterals": "execute_search_loan_collateral_request",
                "payments_account": "execute_search_payments_account_request"
            },
            "get_query_params": {
                "collaterals": "search_loan_collateral",
                "payments_account": "search_payments_account"
            },
            "get_tranformed_config": {
                "collaterals": "search_loan_collateral",
                "payments_account": "search_payments_account"
            }
        },
        "default_document_type": "APP MISCELLANEOUS"
    },
    "ci-ventures-create_loan_contact": {
        "validation_spec": "{}",
        "request_body_spec": "{\n  loanId: .loanId,\n  contact: {\n    firstName: .loan_relations[0].first_name,\n    lastName: .loan_relations[0].last_name,\n    businessPhone: (.loan_relations[0].work_phone | tostring | if length == 10 then \"\\(.[0:3])-\\(.[3:6])-\\(.[6:10])\" else . end),\n    homePhone: (.loan_relations[0].home_phone | tostring | if length == 10 then \"\\(.[0:3])-\\(.[3:6])-\\(.[6:10])\" else . end),\n    mobilePhone: (.loan_relations[0].cell_phone | tostring | if length == 10 then \"\\(.[0:3])-\\(.[3:6])-\\(.[6:10])\" else . end),\n    taxId: .loan_relations[0].formatted_tin,\n    taxIdType: .loan_relations[0].tin_type,\n    citizenship: (if .loan_relations[0].us_citizenship == true then \"USCitizen\" else \"USCitizen\" end),\n    dateOfBirth: .loan_relations[0].dob,\n    email: .loan_relations[0].email,\n    homeAddress: (.loan_relations[0].relation_addresses[] | select(.address_type == \"permanent\") | {\n      city: .city,\n      street1: .address_line_1,\n      street2: .address_line_2,\n      postalCode: \"\\(.zip_code)+\\(.zip_code_plus4)\",\n      countryCode: (if .country == \"\" then \"US\" else .country end),\n      stateCode: .state\n    })\n  },\n  memberOf: [\n    {\n      loanEntityId: .loan_relations[0].memberOf.id,\n      ownershipPercentage: .loan_relations[0].memberOf.ownership_percentage,\n      signer: .loan_relations[0].memberOf.is_signer,\n      controllingMember: .loan_relations[0].memberOf.is_ben_owner_by_control\n    }\n  ]\n}",
        "response_body_spec": "{\n  apiSuccess: (.apiSuccess and (.responses.succeeded // false)),\n  responses: (if (.apiSuccess and (.responses.succeeded // false)) then \n    {customerid: .responses.result.id} \n  else \n    null \n  end),\n  errors: (if (.apiSuccess and (.responses.succeeded // false)) then \n    null \n  else \n    {\n      errorNum: .errors.errorNum,\n      errorMsg: .errors.errorMsg\n    } \n  end)\n}",
        "request_body_spec_config": "{}",
        "response_body_spec_config": "{}"
    },
    "ci-ventures-create_loan_company": {
        "validation_spec": "{}",
        "request_body_spec": "{\n  company: {\n    name: (.loan_relations[0].business_name? // null),\n    entityType: ($entityType[.loan_relations[0].entity_type] // null),\n    role: \"LoanEntity\",\n    businessPhone: (.loan_relations[0].work_phone? | if . then tostring | if length == 10 then \"\\(.[0:3])-\\(.[3:6])-\\(.[6:10])\" else . end else null end),\n    email: (.loan_relations[0].email? // null),\n    website: null,\n    taxId: (.loan_relations[0].formatted_tin? // null),\n    taxIdType: (.loan_relations[0].tin_type? // null),\n    dunsNumber: null,\n    address: (try (.loan_relations[0].relation_addresses[]? | select(.address_type == \"mailing\") | {\n      city: .city?,\n      street1: .address_line_1?,\n      street2: .address_line_2?,\n      postalCode: (if .zip_code_plus4? and .zip_code_plus4 != \"\" then \"\\(.zip_code?)+\\(.zip_code_plus4)\" else .zip_code? end),\n      countryCode: (if .country? == \"\" then \"US\" else .country? end),\n      stateCode: .state?\n    }) // null),\n    establishedDate: (.loan_relations[0].business_established_date? // null),\n    currentOwnershipEstablishedDate: (.loan_relations[0].business_established_date? // null),\n    stateOfFormation: (.loan_relations[0].state_of_establishment? // null),\n    naicsCode: ( if .loan_relations[0].naics_code then .loan_relations[0].naics_code | tostring else null end ),\n    creditScore: (try (.loan_aggregator[]? | select(.aggregator_type == \"fico\" and .is_latest == true) | .details.fico.principals[]? | select(.SSN == .loan_relations[0].tin?) | .ficoScore? | tonumber) // null),\n    creditScoreDate: (try (.loan_aggregator[]? | select(.aggregator_type == \"fico\" and .is_latest == true) | (if .modified? then .modified | split(\"T\")[0] else \"\" end)) // null)\n  },\n  loanId: .loanId?,\n  association: (if .loan_relations[0].is_primary_borrower? then \"Operating Company\" else \"Affiliate\" end),\n  primary: (.loan_relations[0].is_primary_borrower? // false),\n  borrower: false,\n  guaranteeType: (if (.loan_relations[0].ownership_percentage? | tonumber? // 0) > 20 then \"Unsecured Full\" else \"Unsecured Limited\" end),\n  dbaName: (.loan_relations[0].dba_name? // null),\n  employeeCount: (.loan_relations[0].number_of_employees? // null),\n  annualRevenue: (.loan_relations[0].details.annual_business_revenue? // null)\n}",
        "response_body_spec": "{\n  apiSuccess: (.apiSuccess and (.responses.succeeded // false)),\n  responses: (if (.apiSuccess and (.responses.succeeded // false)) then \n    {customerid: .responses.result.id} \n  else \n    null \n  end),\n  errors: (if (.apiSuccess and (.responses.succeeded // false)) then \n    null \n  else \n    {\n      errorNum: .errors.errorNum,\n      errorMsg: .errors.errorMsg\n    } \n  end)\n}",
        "request_body_spec_config": "{\n \"entityType\":{\n \"single_member_llc\":\"Limited Liability Company Single Member\",\n \"sole_proprietor\":\"Sole Proprietorship\",\n \"partnership\":\"Partnership\",\n \"llc\":\"Limited Liability Company\",\n \"llc_as_s_corp\":\"Limited Liability Company\",\n \"llc_as_c_corp\":\"Limited Liability Company\",\n \"llc_as_partnership\":\"Limited Liability Partnership\",\n \"s_corp\":\"S Corporation\",\n \"c_corp\":\"C Corporation\"\n }\n}",
        "response_body_spec_config": "{}"
    },
    "ci-ventures-update_loan_contact":{
       "validation_spec": "{}",
        "request_body_spec": "{\n  contact: {\n    firstName: .loan_relations[0].first_name,\n    lastName: .loan_relations[0].last_name,\n    businessPhone: (.loan_relations[0].work_phone | tostring | if length == 10 then \"\\(.[0:3])-\\(.[3:6])-\\(.[6:10])\" else . end),\n    homePhone: (.loan_relations[0].home_phone | tostring | if length == 10 then \"\\(.[0:3])-\\(.[3:6])-\\(.[6:10])\" else . end),\n    mobilePhone: (.loan_relations[0].cell_phone | tostring | if length == 10 then \"\\(.[0:3])-\\(.[3:6])-\\(.[6:10])\" else . end),\n    taxId: .loan_relations[0].formatted_tin,\n    taxIdType: .loan_relations[0].tin_type,\n    citizenship: (if .loan_relations[0].us_citizenship == true then \"USCitizen\" else \"USCitizen\" end),\n    dateOfBirth: .loan_relations[0].dob,\n    email: .loan_relations[0].email,\n    homeAddress: (.loan_relations[0].relation_addresses[] | select(.address_type == \"permanent\") | {\n      city: .city,\n      street1: .address_line_1,\n      street2: .address_line_2,\n      postalCode: \"\\(.zip_code)+\\(.zip_code_plus4)\",\n      countryCode: (if .country == \"\" then \"US\" else .country end),\n      stateCode: .state\n    })\n  }\n}",
        "response_body_spec": "{\n  apiSuccess: (.apiSuccess and (.responses.succeeded // false)),\n  responses: (if (.apiSuccess and (.responses.succeeded // false)) then \n    {customerid: .responses.result.id} \n  else \n    null \n  end),\n  errors: (if (.apiSuccess and (.responses.succeeded // false)) then \n    null \n  else \n    {\n      errorNum: .errors.errorNum,\n      errorMsg: .errors.errorMsg\n    } \n  end)\n}",
        "request_body_spec_config": "{}",
        "response_body_spec_config": "{}"
    },
    "ci-ventures-update_loan_company": {
        "validation_spec": "{}",
        "request_body_spec": "{\n  company: {\n    name: (.loan_relations[0].business_name? // null),\n    entityType: ($entityType[.loan_relations[0].entity_type] // null),\n    role: \"LoanEntity\",\n    businessPhone: (.loan_relations[0].work_phone? | if . then tostring | if length == 10 then \"\\(.[0:3])-\\(.[3:6])-\\(.[6:10])\" else . end else null end),\n    email: (.loan_relations[0].email? // null),\n    website: null,\n    taxId: (.loan_relations[0].formatted_tin? // null),\n    taxIdType: (.loan_relations[0].tin_type? // null),\n    dunsNumber: null,\n    address: (try (.loan_relations[0].relation_addresses[]? | select(.address_type == \"mailing\") | {\n      city: .city?,\n      street1: .address_line_1?,\n      street2: .address_line_2?,\n      postalCode: (if .zip_code_plus4? and .zip_code_plus4 != \"\" then \"\\(.zip_code?)+\\(.zip_code_plus4)\" else .zip_code? end),\n      countryCode: (if .country? == \"\" then \"US\" else .country? end),\n      stateCode: .state?\n    }) // null),\n    establishedDate: (.loan_relations[0].business_established_date? // null),\n    currentOwnershipEstablishedDate: (.loan_relations[0].business_established_date? // null),\n    stateOfFormation: (.loan_relations[0].state_of_establishment? // null),\n    naicsCode: ( if .loan_relations[0].naics_code then .loan_relations[0].naics_code | tostring else null end ),\n    creditScore: (try (.loan_aggregator[]? | select(.aggregator_type == \"fico\" and .is_latest == true) | .details.fico.principals[]? | select(.SSN == .loan_relations[0].tin?) | .ficoScore? | tonumber) // null),\n    creditScoreDate: (try (.loan_aggregator[]? | select(.aggregator_type == \"fico\" and .is_latest == true) | (if .modified? then .modified | split(\"T\")[0] else \"\" end)) // null)\n  },\n  association: (if .loan_relations[0].is_primary_borrower? then \"Operating Company\" else \"Affiliate\" end),\n  primary: (.loan_relations[0].is_primary_borrower? // false),\n  borrower: false,\n  guaranteeType: (if (.loan_relations[0].ownership_percentage? | tonumber? // 0) > 20 then \"Unsecured Full\" else \"Unsecured Limited\" end),\n  dbaName: (.loan_relations[0].dba_name? // null),\n  employeeCount: (.loan_relations[0].number_of_employees? // null),\n  annualRevenue: (.loan_relations[0].details.annual_business_revenue? // null)\n}",
        "response_body_spec": "{\n  apiSuccess: (.apiSuccess and (.responses.succeeded // false)),\n  responses: (if (.apiSuccess and (.responses.succeeded // false)) then \n    {customerid: .responses.result.id} \n  else \n    null \n  end),\n  errors: (if (.apiSuccess and (.responses.succeeded // false)) then \n    null \n  else \n    {\n      errorNum: .errors.errorNum,\n      errorMsg: .errors.errorMsg\n    } \n  end)\n}",
        "request_body_spec_config": "{\n \"entityType\":{\n \"single_member_llc\":\"Limited Liability Company Single Member\",\n \"sole_proprietor\":\"Sole Proprietorship\",\n \"partnership\":\"Partnership\",\n \"llc\":\"Limited Liability Company\",\n \"llc_as_s_corp\":\"Limited Liability Company\",\n \"llc_as_c_corp\":\"Limited Liability Company\",\n \"llc_as_partnership\":\"Limited Liability Partnership\",\n \"s_corp\":\"S Corporation\",\n \"c_corp\":\"C Corporation\"\n }\n}",
        "response_body_spec_config": "{}"
    },
    "ci-ventures-search_loan": {
        "validation_spec": "{}",
        "request_body_spec": "{}",
        "response_body_spec": ".",
        "request_body_spec_config": "{}",
        "response_body_spec_config": "{}"
    },
    "ci-ventures-search_loan_collateral": {
        "validation_spec": "{}",
        "request_body_spec": "{\nloanId: .loanId,\nprimary: false,\ncollateralTypeId: .collateralTypeId,\nvalue: .value,\nlienPosition: .lienPosition,\naddress: {\n    city: .address.city,\n    street1: .address.street1,\n    street2: .address.street2,\n    postalCode: .address.postalCode,\n    countryCode: .address.countryCode,\n    stateCode: .address.stateCode\n  },\n uccFiled: .uccFiled,\n\"liens\": []\n\n}",
        "response_body_spec": ".",
        "request_body_spec_config": "{}",
        "response_body_spec_config": "{}"
    },
    "ci-ventures-create_loan_collateral": {
        "validation_spec": "{}",
        "request_body_spec": "{\nloanId: .loanId,\nprimary: false,\ncollateralTypeId: .collateralTypeId,\nvalue: .value,\nlienPosition: .lienPosition,\naddress: {\n    city: .address.city,\n    street1: .address.street1,\n    street2: .address.street2,\n    postalCode: .address.postalCode,\n    countryCode: .address.countryCode,\n    stateCode: .address.stateCode\n  },\n uccFiled: .uccFiled,\n\"liens\": []\n\n}",
        "response_body_spec": "{\n  apiSuccess: (.apiSuccess and (.responses.succeeded // false)),\n  responses: (if (.apiSuccess and (.responses.succeeded // false)) then \n    {customerid: .responses.result.id} \n  else \n    null \n  end),\n  errors: (if (.apiSuccess and (.responses.succeeded // false)) then \n    null \n  else \n    {\n      errorNum: .errors.errorNum,\n      errorMsg: .errors.errorMsg\n    } \n  end)\n}",
        "request_body_spec_config": "{}",
        "response_body_spec_config": "{}"
    },
    "ci-ventures-update_loan_collateral": {
        "validation_spec": "{}",
        "request_body_spec": "{\n collateralTypeId:.collateralTypeId,\nvalue:.value,\nlienPosition:.lienPosition,\n address: {\n    city: .address.city,\n    street1: .address.street1,\n    street2: .address.street2,\n    postalCode: .address.postalCode,\n    countryCode: .address.countryCode,\n    stateCode: .address.stateCode?\n  },\n  uccFiled: .uccFiled,\n  liens: .liens\n}",
        "response_body_spec": "{\n  apiSuccess: (.apiSuccess and (.responses.succeeded // false)),\n  responses: (if (.apiSuccess and (.responses.succeeded // false)) then \n    {customerid: .responses.result.id} \n  else \n    null \n  end),\n  errors: (if (.apiSuccess and (.responses.succeeded // false)) then \n    null \n  else \n    {\n      errorNum: .errors.errorNum,\n      errorMsg: .errors.errorMsg\n    } \n  end)\n}",
        "request_body_spec_config": "{}",
        "response_body_spec_config": "{}"
    },
}

org_config = (
    OrganizationConfiguration.objects.all().order_by("-version_major", "-version_minor", "-version_patch").first()
)
for key, value in interfaces.items():
    configuration, _ = Configuration.objects.update_or_create(
        name=key, interface_type=key, defaults={"details": value}
    )
    org_config.details["GLOBAL"][key] = {"name": configuration.name, "version": configuration.version}
