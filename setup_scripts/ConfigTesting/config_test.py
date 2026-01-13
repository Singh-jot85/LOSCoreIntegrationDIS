import sys, json, os, jq
from pathlib import Path
from jinja2 import Environment

CURRENT_PATH = Path(__file__).resolve(strict=True).parent
CONFIG_FILE_NAME = "config.json"
PAYLOADS_PATH = "payloads"

def read_f(file_path):
    print("📖 Reading file:", file_path)
    with open(file_path, "r") as f:
        content = json.load(f)
    return content

def write_f(file_path, content, content_type="json"):
    print(f"📝 Writing {content_type} file: ", file_path)

    if content_type == "json":
        with open(file_path, "w") as f:
            json.dump(content, f, indent=4)
    else:
        with open(file_path, "w") as f:
            f.write(content)

def test_config_jq(config, payload, api_mode):
    key = "request_body_spec"
    config_key = "request_body_spec_config"

    if api_mode == "response":
        key = "response_body_spec"
        config_key = "response_body_spec_config"

    jq_spec = config.get(key, None)
    jq_config = json.loads(config.get(config_key, "{}"))

    if not jq_spec:
        print(f"\t⚠️ No JQ found in configuration.")
        return

    try:
        output = (
            jq.compile(jq_spec, jq_config).input(payload).first()
        )
    except Exception as e:
        print(f"\t❌ JQ processing failed: {e}")
        return False

    output_path = os.path.join(CURRENT_PATH, PAYLOADS_PATH, f"output_{api_mode}.json")
    print(f"\t✅ JQ processing succeeded. Output in: {output_path}")
    write_f(output_path, output, content_type="json")
    return True

def test_config_xml(config, payload, api_mode):
    xml = config.get("xml_template", None)
    if not xml:
        print(f"\t⚠️ No XML template found in configuration.")
        return

    jinja_env = Environment(
        autoescape=False,
        lstrip_blocks=True,
        trim_blocks=True
    )

    try:
        template = jinja_env.from_string(xml)
        output = template.render(payload)
    except Exception as e:
        print(f"\t❌ XML processing failed: {e}")
        return False

    output_path = os.path.join(CURRENT_PATH, PAYLOADS_PATH, f"output_{api_mode}.xml")
    print(f"\t✅ XML processing succeeded. Output in: {output_path}")
    write_f(output_path, output, content_type="xml")
    return True

def main(*args):
    testing_mode = args[1] or "jq"
    payload_file_name = args[2] or "sample_payload.json"
    api_mode = args[3] or "request"

    print("🔍 Loading configuration file for testing...")
    config_path = os.path.join(CURRENT_PATH, PAYLOADS_PATH, CONFIG_FILE_NAME)
    config = read_f(config_path)
    print("✅ Configuration file loaded.")

    print("🔍 Loading sample payload for testing...")
    payload = read_f(os.path.join(CURRENT_PATH, PAYLOADS_PATH, payload_file_name))
    print("✅ Sample payload loaded.")

    print("⌛️ Running config tests...")

    if testing_mode == "jq":
        print("\t⌛️ Running jq config tests...")
        if not test_config_jq(config, payload, api_mode):
            print("\t❌ JQ config tests failed.")
            return            
        print("\t✅ JQ config tests completed.")

    if testing_mode == "xml":
        print("\t⌛️ Running jq config tests...")
        if not test_config_jq(config, payload, api_mode):
            print("\t❌ JQ config tests failed.")
        else:
            print("\t✅ JQ config tests completed.")

        print("\t⌛️ Running XML config tests...")
        jq_output_path = os.path.join(CURRENT_PATH, PAYLOADS_PATH, f"output_{api_mode}.json")
        jq_output = read_f(jq_output_path)
        if not test_config_xml(config, jq_output, api_mode):
            print("\t❌ XML config tests failed.")
            return
        print("\t✅ XML config tests completed.")

    print("✅ Config testing completed.")

if __name__ == "__main__":
    args = sys.argv
    main(*args)
