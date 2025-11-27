import logging
from io import BytesIO

import pkg_resources
from lxml import etree

LOGGER = logging.getLogger(__name__)

XSD_PACKAGE = "xsd.R2024203"

class PackageResolver(etree.Resolver):
    def resolve(self, system_url, public_id, context):
        filename = system_url.split("/")[-1]
        resource_path = f"{XSD_PACKAGE.replace('.', '/')}/{filename}"
        try:
            xsd_data = pkg_resources.resource_string(__name__, resource_path)
            return self.resolve_string(xsd_data, context)
        except FileNotFoundError:
            LOGGER.error("Failed to resolve imported XSD: %s", filename)
            return None
        except Exception as e:
            LOGGER.error("Resolver error: %s", e)
            return None


class XMLValidator:
    def __init__(self, xsd_name):
        self.xsd_name = xsd_name
        self.schema = self._load_schema()

    def _load_schema(self):
        try:
            parser = etree.XMLParser()
            parser.resolvers.add(PackageResolver())

            resource_path = f"{XSD_PACKAGE.replace('.', '/')}/{self.xsd_name}.xsd"
            xsd_content = pkg_resources.resource_string(__name__, resource_path)
            schema_doc = etree.parse(BytesIO(xsd_content), parser)
            return etree.XMLSchema(schema_doc)

        except etree.XMLSchemaParseError as e:
            raise Exception(f"XSD schema parsing error: {e}")
        except Exception as e:
            raise Exception(f"Error loading XSD schema: {e}")

    def _extract_soap_body(self, xml_content):
        try:
            root = etree.fromstring(xml_content.lstrip().encode("utf-8"))
            namespaces = {"soap": "http://schemas.xmlsoap.org/soap/envelope/"}
            body = root.find("soap:Body", namespaces)
            if body is not None and len(body):
                return etree.tostring(body[0])
            return etree.tostring(root)
        except Exception as e:
            raise Exception(f"Failed to extract SOAP body: {e}")

    def validate(self, xml_content, strip_soap_envelope=True):
        try:
            if strip_soap_envelope:
                xml_content = self._extract_soap_body(xml_content)
            xml_doc = etree.fromstring(
                xml_content.lstrip().encode("utf-8")
                if isinstance(xml_content, str)
                else xml_content
            )
        except etree.XMLSyntaxError as e:
            raise Exception(f"XML parsing error: {e}")

        try:
            self.schema.assertValid(xml_doc)
            return True
        except etree.DocumentInvalid as e:
            # TODO: Raise the exception instead of sentry
            LOGGER.debug("XSD Validation Failure: %s", e)
            raise Exception("XSD Validation Failure:") from e
