{
    CustSrch: {
        TaxId: ((.loan_relations[0] | .tin) // null)
    }
    PersonName: {
        ComName: ((.loan_relations[0] | .full_name) // null)
    }
}