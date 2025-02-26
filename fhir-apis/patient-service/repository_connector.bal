import ballerina/http;
import ballerinax/health.clients.fhir;
import ballerinax/health.fhir.r4;
import ballerinax/health.fhir.r4.parser;
import ballerinax/health.fhir.r4.uscore501;

// http:OAuth2ClientCredentialsGrantConfig ehrSystemAuthConfig = {
//     tokenUrl: "https://login.microsoftonline.com/da76d684-740f-4d94-8717-9d5fb21dd1f9/oauth2/token",
//     clientId: "",
//     clientSecret: "",
//     scopes: ["system/Patient.read, system/Patient.write"],
//     optionalParams: {
//         "resource": "https://ohfhirrepositorypoc-ohfhirrepositorypoc.fhir.azurehealthcareapis.com"
//     }
// };

// fhir:FHIRConnectorConfig ehrSystemConfig = {
//     baseURL: "https://ohfhirrepositorypoc-ohfhirrepositorypoc.fhir.azurehealthcareapis.com/",
//     mimeType: fhir:FHIR_JSON,
//     authConfig: ehrSystemAuthConfig
// };

// isolated fhir:FHIRConnector fhirConnectorObj = check new (ehrSystemConfig);

isolated uscore501:USCorePatientProfile[] patients = [];
isolated int createOperationNextId = 102;

public isolated function create(json payload) returns r4:FHIRError|uscore501:USCorePatientProfile {
    uscore501:USCorePatientProfile|error patient = parser:parse(payload, uscore501:USCorePatientProfile).ensureType();

    if patient is error {
        return r4:createFHIRError(patient.message(), r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_BAD_REQUEST);
    } else {
        lock {
            patient.id = (++createOperationNextId).toBalString();
        }

        lock {
            patients.push(patient.clone());
        }

        return patient;
    }
}

public isolated function getById(string id) returns r4:FHIRError|uscore501:USCorePatientProfile {
    lock {
        foreach var item in patients {
            string result = item.id ?: "";

            if result == id {
                return item.clone();
            }
        }
    }
    return r4:createFHIRError(string `Cannot find a Patient resource with id: ${id}`, r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_FOUND);
}

public isolated function update(json payload) returns r4:FHIRError|fhir:FHIRResponse {
    return r4:createFHIRError("Not implemented", r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_IMPLEMENTED);

}

public isolated function patchResource(string 'resource, string id, json payload) returns r4:FHIRError|fhir:FHIRResponse {
    return r4:createFHIRError("Not implemented", r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_IMPLEMENTED);
}

public isolated function delete(string 'resource, string id) returns r4:FHIRError|fhir:FHIRResponse {
    return r4:createFHIRError("Not implemented", r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_IMPLEMENTED);

}

public isolated function search(string 'resource, map<string[]>? searchParameters = ()) returns r4:FHIRError|r4:Bundle {
    r4:Bundle bundle = {
        'type: "collection"
    };

    if searchParameters is map<string[]> {
        if searchParameters.keys().count() == 1 {
            lock {
                r4:BundleEntry[] bundleEntries = [];
                foreach var item in patients {
                    r4:BundleEntry bundleEntry = {
                        'resource: item
                    };
                    bundleEntries.push(bundleEntry);
                }
                r4:Bundle BundleClone = bundle.clone();
                BundleClone.entry = bundleEntries;
                return BundleClone.clone();
            }
        }

        foreach var 'key in searchParameters.keys() {
            match 'key {
                "_id" => {
                    uscore501:USCorePatientProfile byId = check getById(searchParameters.get('key)[0]);
                    bundle.entry = [
                        {
                            'resource: byId
                        }
                    ];
                    return bundle;
                }
                _ => {
                    return r4:createFHIRError(string `Not supported search parameter: ${'key}`, r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_IMPLEMENTED);
                }
            }
        }
    }

    return bundle;
}

function init() returns error? {
    lock {
        json patientJson = {
            "resourceType": "Patient",
            "id": "101",
            "meta": {
                "profile": [
                    "http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient"
                ]
            },
            "text": {
                "status": "generated",
                "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">\n\t\t\t<p>\n\t\t\t\t<b>Generated Narrative with Details</b>\n\t\t\t</p>\n\t\t\t<p>\n\t\t\t\t<b>id</b>: example</p>\n\t\t\t<p>\n\t\t\t\t<b>identifier</b>: Medical Record Number = 1032702 (USUAL)</p>\n\t\t\t<p>\n\t\t\t\t<b>active</b>: true</p>\n\t\t\t<p>\n\t\t\t\t<b>name</b>: Amy V. Shaw </p>\n\t\t\t<p>\n\t\t\t\t<b>telecom</b>: ph: 555-555-5555(HOME), amy.shaw@example.com</p>\n\t\t\t<p>\n\t\t\t\t<b>gender</b>: </p>\n\t\t\t<p>\n\t\t\t\t<b>birthsex</b>: Female</p>\n\t\t\t<p>\n\t\t\t\t<b>birthDate</b>: Feb 20, 2007</p>\n\t\t\t<p>\n\t\t\t\t<b>address</b>: 49 Meadow St Mounds OK 74047 US </p>\n\t\t\t<p>\n\t\t\t\t<b>race</b>: White, American Indian or Alaska Native, Asian, Shoshone, Filipino</p>\n\t\t\t<p>\n\t\t\t\t<b>ethnicity</b>: Hispanic or Latino, Dominican, Mexican</p>\n\t\t</div>"
            },
            "extension": [
                {
                    "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-race",
                    "extension": [
                        {
                            "url": "ombCategory",
                            "valueCoding": {
                                "system": "urn:oid:2.16.840.1.113883.6.238",
                                "code": "2106-3",
                                "display": "White"
                            }
                        },
                        {
                            "url": "ombCategory",
                            "valueCoding": {
                                "system": "urn:oid:2.16.840.1.113883.6.238",
                                "code": "1002-5",
                                "display": "American Indian or Alaska Native"
                            }
                        },
                        {
                            "url": "ombCategory",
                            "valueCoding": {
                                "system": "urn:oid:2.16.840.1.113883.6.238",
                                "code": "2028-9",
                                "display": "Asian"
                            }
                        },
                        {
                            "url": "detailed",
                            "valueCoding": {
                                "system": "urn:oid:2.16.840.1.113883.6.238",
                                "code": "1586-7",
                                "display": "Shoshone"
                            }
                        },
                        {
                            "url": "detailed",
                            "valueCoding": {
                                "system": "urn:oid:2.16.840.1.113883.6.238",
                                "code": "2036-2",
                                "display": "Filipino"
                            }
                        },
                        {
                            "url": "text",
                            "valueString": "Mixed"
                        }
                    ]
                },
                {
                    "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity",
                    "extension": [
                        {
                            "url": "ombCategory",
                            "valueCoding": {
                                "system": "urn:oid:2.16.840.1.113883.6.238",
                                "code": "2135-2",
                                "display": "Hispanic or Latino"
                            }
                        },
                        {
                            "url": "detailed",
                            "valueCoding": {
                                "system": "urn:oid:2.16.840.1.113883.6.238",
                                "code": "2184-0",
                                "display": "Dominican"
                            }
                        },
                        {
                            "url": "detailed",
                            "valueCoding": {
                                "system": "urn:oid:2.16.840.1.113883.6.238",
                                "code": "2148-5",
                                "display": "Mexican"
                            }
                        },
                        {
                            "url": "text",
                            "valueString": "Hispanic or Latino"
                        }
                    ]
                },
                {
                    "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex",
                    "valueCode": "F"
                }
            ],
            "identifier": [
                {
                    "use": "usual",
                    "type": {
                        "coding": [
                            {
                                "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                                "code": "MR",
                                "display": "Medical Record Number"
                            }
                        ],
                        "text": "Medical Record Number"
                    },
                    "system": "http://hospital.smarthealthit.org",
                    "value": "1032702"
                }
            ],
            "active": true,
            "name": [
                {
                    "family": "Shaw",
                    "given": [
                        "Amy",
                        "V."
                    ]
                }
            ],
            "telecom": [
                {
                    "system": "phone",
                    "value": "555-555-5555",
                    "use": "home"
                },
                {
                    "system": "email",
                    "value": "amy.shaw@example.com"
                }
            ],
            "gender": "female",
            "birthDate": "2007-02-20",
            "address": [
                {
                    "line": [
                        "49 Meadow St"
                    ],
                    "city": "Mounds",
                    "state": "OK",
                    "postalCode": "74047",
                    "country": "US"
                }
            ]
        };
        uscore501:USCorePatientProfile patient = check parser:parse(patientJson, uscore501:USCorePatientProfile).ensureType();
        patients.push(patient);
    }

}
