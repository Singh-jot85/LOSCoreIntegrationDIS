if .object_type == "LoanTermChange-LOC" then
    {revolvingTermEndDate: (.revolving_term_end_date // null)}
elif .object_type == "LoanTermChange-MaturityDate" then
    {maturityDate: (.maturity_date // null)}
elif .object_type == "LoanTermChange-RateCap" then
    {
        interestRateCeilingPercent: (.max_rate // .product.max_rate),
        interestRateFloorPercent: (.min_rate // .product.min_rate)
    }
elif .object_type == "LoanTermChange-LoanAmount" then
    {
        amountFinanced: (.approved_amount // null),
        revolvingTermEndDate: .revolving_term_end_date,
        maturityDate: (.maturity_date // null),
        interestRateCeilingPercent: (.max_rate // .product.max_rate),
        interestRateFloorPercent: (.min_rate // .product.min_rate)
    }
else empty
end