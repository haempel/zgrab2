# zschema sub-schema for zgrab2's zgrab2 module
# Registers zgrab2-zgrab2 globally, and zgrab2 with the main zgrab2 schema.
from zschema.leaves import *
from zschema.compounds import *
import zschema.registry

import zcrypto_schemas.zcrypto as zcrypto
import zgrab2

zgrab2_scan_response = SubRecord({
    "result": SubRecord({
        # TODO FIXME IMPLEMENT SCHEMA
    })
}, extends=zgrab2.base_scan_response)

zschema.registry.register_schema("zgrab2-zgrab2", zgrab2_scan_response)

zgrab2.register_scan_response_type("zgrab2", zgrab2_scan_response)
