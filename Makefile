.PHONY: us, tc

update-scripts:
	python3 setup_scripts/fetch_configs.py
us: update-scripts

type=jq
file_name=sample_payload.json
api_mode=request
test-configurations:
	python3 setup_scripts/ConfigTesting/config_test.py ${type} ${file_name} ${api_mode}
tc: test-configurations