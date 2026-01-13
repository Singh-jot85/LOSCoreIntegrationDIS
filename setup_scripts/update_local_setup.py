"""
To get all core int interface types.
from los.configurations.models import Configuration
core_int_config_names = []
for name, value in Configuration.__dict__.items():
    if name.startswith("CI") and not name.startswith("CI_ETRAN"):
        core_int_config_names.append(value)
"""

import os, json, sys
from django.conf import settings
from django.db import transaction, connection
from los.configurations.models import Configuration
from los.organizations.models import OrganizationConfiguration
from los.integrations.models import CredentialsManager
from pathlib import Path

# Defaults
TENANT_MAP_INTERFACE = "ci-tenant-map"
CONFIGS_FILE_NAME = "configs.json"
ALLOWED_CORE_INTEGRATIONS = ["ventures", "csi", "fiserv", "jackhenry"]

CURRENT_PATH = Path(__file__).resolve(strict=True).parent
ROOT_PATH = CURRENT_PATH.parent
print("🛣️ PATHS: \n\tCurrent Path:", CURRENT_PATH, "\n\tRoot Path:", ROOT_PATH)

CONFIG_FILE_NAME = "configs.json"
CREDS_FILE_NAME = "creds.json"
INTERFACE_TYPE_FILE_NAME = "interface_type.json"


tenant_map = {
    "ventures": {
        "module": "core_integration.ventures.ventures_adapter",
        "adapter": "VenturesAdapter",
        "corebanking_name": "ventures",
    },
    "csi": {
        "module": "core_integration.csi.csi_adapter",
        "adapter": "CsiAdapter",
        "corebanking_name": "csi",
    },
    "fiserv": {
        "module": "core_integration.fiserv.fiserv_adapter",
        "adapter": "FiservAdapter",
        "corebanking_name": "fiserv",
    },
    "jackhenry": {
        "module": "core_integration.jackhenry.jackhenry_adapter",
        "adapter": "JHAdapter",
        "corebanking_name": "jackhenry",
    },
}

def update_tenant_map_and_creds(integration):
    with transaction.atomic():
        # Update Tenant Map
        tenant_maps = Configuration.objects.filter(interface_type=TENANT_MAP_INTERFACE)
        for config in tenant_maps:
            config.details = {str(connection.schema_name): tenant_map.get(integration, {})}
            config.save()

        # Update/Create Creds manager
        creds_manager, created = CredentialsManager.objects.get_or_create(
            interface_type=f"ci-{integration}"
        )
        creds_manager.details = config_json.get("CREDS", {}).get(integration.upper(), {})
        creds_manager.save()

        # Update Organization Config for corebanking_name
        organization_config = Configuration.objects.filter(
            interface_type="organization_config"
        )
        for config in organization_config:
            details = config.details
            details["corebanking_name"] = integration
            config.details = details
            config.save()

    return True

def update_configs(config_json, integration):
    with transaction.atomic():
        # Update all the configs
        configs = config_json.get(integration.upper(), {})
        for interface_type, details in configs.items():
            config_obj = Configuration.objects.filter(
                interface_type=interface_type, name=interface_type
            )
            if config_obj:
                for config in config_obj:
                    config.details = details
                    config.save()
            else:
                configuration = Configuration.objects.create(
                    name=interface_type, interface_type=interface_type, details=details
                )
                org_config = OrganizationConfiguration.objects.all()
                for org in org_config:
                    org.details["GLOBAL"][interface_type] = {
                        "name": configuration.name,
                        "version": configuration.version,
                    }
                    org.save()

    return True

def read_f(file_path):
    print("📖 Reading file:", file_path)
    with open(file_path, "r") as f:
        content = json.load(f)
    return content

def write_f(file_path, content):
    print("📝 Writing file:", file_path)
    try:
        with open(file_path, "r") as f:
            initial_content = json.load(f)
    except FileNotFoundError:
        initial_content = {}

    initial_content.update(content)
    with open(file_path, "w") as f:
        json.dump(initial_content, f, indent=4)


def generate_config_json():
    def walk_dir_for_configs(dir_name) -> dict:
        config_dict = {}

        dir_path = os.path.join(ROOT_PATH, dir_name, "Configs")

        if not os.path.exists(dir_path):
            print(f"⚠️ Directory not found: {dir_path}")
            return config_dict
        if not os.path.isdir(dir_path):
            print(f"⚠️ Path is not a directory: {dir_path}")
            return config_dict

        root, dirs, files = next(os.walk(dir_path))
        print("🔍 Walking through directory + subdirectories:", root, dirs, sep="\n\t")

        for file in files:
            if file.endswith(".json"):
                config_name = file.split(".json")[0]
                config_content = read_f(os.path.join(root, file))
                config_dict[config_name] = config_content

        # Check for versioned directories
        if dirs:
            dirs.sort()
            latest_release_dir = dirs[-1]
            for root, _, files in os.walk(os.path.join(root, latest_release_dir)):
                for file in files:
                    if file.endswith(".json"):
                        config_name = file.split(".json")[0]
                        config_content = read_f(os.path.join(root, file))
                        config_dict[config_name] = config_content

        return config_dict

    interface_list = read_f(os.path.join(CURRENT_PATH, INTERFACE_TYPE_FILE_NAME))

    integrations = {}
    for config_interface in interface_list:
        integration = config_interface.split("-")[1]

        if integration not in integrations or integrations[integration] is False:
            integrations[integration] = False
            try:
                configs = walk_dir_for_configs(dir_name=integration)
            except Exception as e:
                print(f"⚠️ Error walking directory for {integration}: {e}")
                configs = {}
            write_f(
                os.path.join(CURRENT_PATH, CONFIG_FILE_NAME),
                {integration.upper(): configs},
            )
            integrations[integration] = True

    return integrations


def main():
    """
    python update_local_setup.py <mode> [integration]
        - python3 update_local_setup.py 0
        - python3 update_local_setup.py 1 jackhenry
    """
    args = sys.argv
    mode = args[1]
    if mode in ["get", 0]:
        print("🔄 Generating configuration JSON...")

        generate_config_json()
        print("✅ Configuration JSON generation completed.")

        write_f(
            os.path.join(CURRENT_PATH, CONFIG_FILE_NAME),
            {"CREDS": read_f(os.path.join(CURRENT_PATH, CREDS_FILE_NAME))},
        )
        print("✅ Credentials JSON appended to configuration JSON.")

    if mode in ["update", 1]:
        print("🔄 Updating local setup from configuration JSON...")

        if args[2] not in ALLOWED_CORE_INTEGRATIONS:
            print(f"❌ Integration '{args[2]}' not allowed. Choose from: {ALLOWED_CORE_INTEGRATIONS}")
            return

        integration = args[2]
        update_tenant_map_and_creds(integration=integration)
        print("✅ Tenant map and credentials manager update completed.")

        config_json = read_f(os.path.join(CURRENT_PATH, CONFIG_FILE_NAME))
        update_configs(config_json=config_json, integration=integration)
        print("✅ Configurations update completed.")

        print("✅ Local setup completed.")

if __name__ == "__main__":
    main()
