import sys, os
from lxml import etree
import xml.etree.ElementTree as ET
from jh_xml_validator import XMLValidator

def load_xml(file_name):
    base_dir = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(base_dir, file_name)

    with open(file_path, "r", encoding="utf-8") as f:
        xml_content = f.read()

    return xml_content


def extract_body_from_xml(xml_content): # Extract SOAP body
	root = etree.fromstring(xml_content.lstrip().encode("utf-8"))
	namespaces = {"soap": "http://schemas.xmlsoap.org/soap/envelope/"}
	body = root.find("soap:Body", namespaces)
	if body is not None and len(body):
		print("Body found Successfully in XML")
		return etree.tostring(body[0])
	else:
		return etree.tostring(root)

def is_xsd_valid(xml_content, xsd_name):
    xml_content = extract_body_from_xml(xml_content)
	
    # Load XML Doc
	cleaned_str = None
	if isinstance(xml_content, str):
		cleaned_str = xml_content.lstrip().encode("utf-8") 
	else:
		cleaned_str = xml_content 

    xml_doc = etree.fromstring(cleaned_str)

	try:
		validator = XMLValidator(xsd_name)
		validator.schema.assertValid(xml_doc)
	except Exception as exc:
		raise Exception from exc

	return True	

if __name__ == "__main__":
	file_name = sys.args[1]
	xsd_name = sys.args[2]

	xml_content = load_xml(file_name)

	try:
		if is_xsd_valid(xml_content, xsd_name):
			print("✅ XSD validation success")
		else:
			print("❌ XSD validation failed")
		
	except Exception as e:
		raise Exception from e