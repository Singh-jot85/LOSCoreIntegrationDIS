{
    taxIdType: ((.loan_relations[] | (if .tin_type == "TIN" then "ITIN" else .tin_type end)) // null),
    taxId: ((.loan_relations[] | .tin) // null) 
}