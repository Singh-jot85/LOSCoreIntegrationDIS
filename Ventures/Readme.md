# Some tenant specific points to note down

## Key Points:
- For Ventures we have three different tenants(Multi-tenancy on core side):
    - LFCU
    - CDC
    - TrialLSP
- LFCU and TrailLSP are 80% similar with some minor mapping changes
- Custom data mappings only work in CDC and TrialLSP
- For all the tenants only `ci-ventures-create_loan` differ rest all configs remain same.
- MF contains multi-facilities changes that were to be done after loan_relations refactor.