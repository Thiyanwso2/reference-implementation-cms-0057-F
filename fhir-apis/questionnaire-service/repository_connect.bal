import ballerina/http;
import ballerinax/health.clients.fhir;
import ballerinax/health.fhir.r4;
import ballerinax/health.fhir.r4.international401;
import ballerinax/health.fhir.r4.parser;

isolated international401:Questionnaire[] questionnaires = [];
isolated int createOperationNextId = 5;

public isolated function create(Questionnaire payload) returns r4:FHIRError|international401:Questionnaire {
    international401:Questionnaire|error patient = parser:parseWithValidation(payload.toJson(), international401:Questionnaire).ensureType();

    if patient is error {
        return r4:createFHIRError(patient.message(), r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_BAD_REQUEST);
    } else {
        lock {
            patient.id = (++createOperationNextId).toBalString();
        }

        lock {
            questionnaires.push(patient.clone());
        }

        return patient;
    }
}

public isolated function getById(string id) returns r4:FHIRError|international401:Questionnaire {
    lock {
        foreach var item in questionnaires {
            string result = item.id ?: "";

            if result == id {
                return item.clone();
            }
        }
    }
    return r4:createFHIRError(string `Cannot find a Questionnaire resource with id: ${id}`, r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_FOUND);
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
                foreach var item in questionnaires {
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
                    international401:Questionnaire byId = check getById(searchParameters.get('key)[0]);
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
        json questionnaireJson = {
            "resourceType": "Questionnaire",
            "id": "f201",
            "text": {
                "status": "generated",
                "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">\n      <pre>Lifelines Questionnaire 1 part 1\n  1. Do you have allergies?\n  2. General Questions:\n    2.a) What is your gender?\n    2.b) What is your date of birth?\n    2.c) What is your country of birth?\n    2.d) What is your marital status?\n    3. Intoxications:\n      3.a) Do you smoke?\n      3.b) Do you drink alcohol?</pre>\n    </div>"
            },
            "url": "http://hl7.org/fhir/Questionnaire/f201",
            "status": "active",
            "subjectType": [
                "Patient"
            ],
            "date": "2010",
            "code": [
                {
                    "system": "http://example.org/system/code/lifelines/nl",
                    "code": "VL 1-1, 18-65_1.2.2",
                    "display": "Lifelines Questionnaire 1 part 1"
                }
            ],
            "item": [
                {
                    "linkId": "1",
                    "text": "Do you have allergies?",
                    "type": "boolean"
                },
                {
                    "linkId": "2",
                    "text": "General questions",
                    "type": "group",
                    "item": [
                        {
                            "linkId": "2.1",
                            "text": "What is your gender?",
                            "type": "string"
                        }
                    ]
                }
            ]
        };

        international401:Questionnaire questionnaire = check parser:parse(questionnaireJson, international401:Questionnaire).ensureType();
        questionnaires.push(questionnaire);
    }

}
