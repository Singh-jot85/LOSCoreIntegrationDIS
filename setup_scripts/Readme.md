## These Scripts are meant to initialize core integration in local devlopment setup, latest config can be picked from any testing env, these are just a reference to get started.

### Integration Specific Key Points:

#### Ventures:
- Has three differnt tenants, use apt. configs for correct setup
- Add credential manager with name `ci-ventures` and get the creds from any testing env.

#### Fiserv:
- For testing fiserv integration we need port forward from UAT env. of los, as only its IP is whitelisted by FISERV.
- Follow these steps for `port forwarding`:
    - Get the preprod `.pem` and run these command in same directory as the `.pem` file.
    - `chmod 400 <file_name>.pem`
    - `ssh -i ct-los-preprod-bastion-primary.pem -L 9178:10.170.27.30:443 ec2-user@13.59.3.92`
- Add credential manager with name `ci-fiserv` and get the creds from any testing env.
- Update with latest creds but donot change `api_url` as its required for local setups (docker builds)

#### Jackhenry:
- XMLs must be validated through an XSD validator, use the added validator file to do so, before making any new changes to the config.
- Add credential manager with name `ci-jackhenry` and get the creds from any testing env.

### Config Testing:
`python3 setup_scripts/ConfigTesting/test_configurations.py jq sample_payload.json request`
`python3 setup_scripts/ConfigTesting/test_configurations.py jq sample_payload.json response`
`python3 setup_scripts/ConfigTesting/test_configurations.py xml sample_payload.json request`
`python3 setup_scripts/ConfigTesting/test_configurations.py xml sample_payload.json response`