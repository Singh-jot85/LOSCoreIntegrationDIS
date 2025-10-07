(
({
    "SSN":"S",
    "EIN":"E"
} as $tinType |
)    
{
    tinType: .loan_relations[] | $tinType[.tin_type],
    tin: .loan_relations[] | .tin 
}
)