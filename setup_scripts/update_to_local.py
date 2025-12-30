import os, json
from django.conf import settings
from django.db import transaction, connection
from los.configurations.models import Configuration
from los.organizations.models import OrganizationConfiguration
from los.integrations.models import CredentialsManager

INTEGRATION = "jackhenry"
TENANT_MAP_INTERFACE = "ci-tenant-map"
CONFIGS_FILE_NAME = "configs.json"

config_json = {}
with open(os.path.join(settings.ROOT_DIR, CONFIGS_FILE_NAME), "r") as f:
    config_json = json.load(f)

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

with transaction.atomic():
    # Update Tenant Map
    tenant_maps = Configuration.objects.filter(interface_type=TENANT_MAP_INTERFACE)
    for config in tenant_maps:
        config.details = {str(connection.schema_name): tenant_map.get(INTEGRATION, {})}
        config.save()

    # Update/Create Creds manager
    creds_manager, created = CredentialsManager.objects.get_or_create(
        interface_type=f"ci-{INTEGRATION}"
    )
    creds_manager.details = config_json.get("CREDS", {}).get(INTEGRATION.upper(), {})
    creds_manager.save()

    # Update Organization Config for corebanking_name
    organization_config = Configuration.objects.filter(
        interface_type="organization_config"
    )
    for config in organization_config:
        details = config.details
        details["corebanking_name"] = INTEGRATION
        config.details = details
        config.save()

with transaction.atomic():
    # Update all the configs
    configs = config_json.get(INTEGRATION.upper(), {})
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
