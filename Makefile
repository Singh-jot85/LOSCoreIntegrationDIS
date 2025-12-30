.PHONY: us
update-scripts:
	python3 setup_scripts/fetch_configs.py
us: update-scripts