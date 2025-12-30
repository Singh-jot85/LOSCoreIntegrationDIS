import json, os
from pathlib import Path

CURRENT_PATH = Path(__file__).resolve(strict=True).parent
ROOT_PATH = CURRENT_PATH.parent
print("🛣️ PATHS: \n\tCurrent Path:", CURRENT_PATH, "\n\tRoot Path:", ROOT_PATH)

CONFIG_FILE_NAME = "configs.json"
CREDS_FILE_NAME = "creds.json"
INTERFACE_TYPE_FILE_NAME = "interface_type.json"

"""
To get all core int interface types.
from los.configurations.models import Configuration
core_int_config_names = []
for name, value in Configuration.__dict__.items():
    if name.startswith("CI") and not name.startswith("CI_ETRAN"):
        core_int_config_names.append(value)
"""


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


def main():
    generate_config_json()
    print("✅ Configuration JSON generation completed.")

    write_f(
        os.path.join(CURRENT_PATH, CONFIG_FILE_NAME),
        {"CREDS": read_f(os.path.join(CURRENT_PATH, CREDS_FILE_NAME))},
    )
    print("✅ Credentials JSON appended to configuration JSON.")


if __name__ == "__main__":
    main()