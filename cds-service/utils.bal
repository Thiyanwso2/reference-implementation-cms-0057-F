import ballerina/constraint;

// AUTO-GENERATED FILE.
//
// This file is auto-generated by the CDS health tool.
// We do not recommend to modify it.

import ballerina/http;
import ballerinax/health.fhir.cds;

# This method will engage the followings
# Request validation
# Context validation
# Prefetch operation
#
# + hookId - Registered id of the hook being invoked.
# + cdsRequest - Cds request payload.
# + return - return validated cds request, or error as http response.
isolated function preProcessing(string hookId, cds:CdsRequest cdsRequest) returns cds:CdsRequest|http:Response {

    // Check whether user requested Hook with the hookId is in the registered CDS services list
    if (cds:cds_services.filter(s => s.id == hookId).length() > 0) {
        cds:CdsService cdsService = <cds:CdsService>cds:cds_services.filter(s => s.id == hookId)[0];

        cds:CdsRequest|constraint:Error validate = constraint:validate(cdsRequest, cds:CdsRequest);
        if validate is constraint:Error {
            string message = validate.message();
            int statusCode = 400;
            cds:CdsError cdsError = cds:createCdsError(message, statusCode);
            return cds:cdsErrorToHttpResponse(cdsError);
        }

        if (cdsRequest.hook != cdsService.hook) {
            string message = string `CDS service ${hookId} is a not type of ${cdsRequest.hook}. It should be ${cdsService.hook} type hook`;
            int statusCode = 400;
            cds:CdsError cdsError = cds:createCdsError(message, statusCode);
            return cds:cdsErrorToHttpResponse(cdsError);
        }

        //Do context validation
        cds:CdsError? contextValidated = cds:validateContext(cdsRequest, cdsService);
        if contextValidated is cds:CdsError {
            return cds:cdsErrorToHttpResponse(contextValidated);
        }

        //Do Prefetch FHIR data validation
        cds:CdsRequest|cds:CdsError prefetchValidated = cds:validateAndProcessPrefetch(cdsRequest, cdsService);
        if prefetchValidated is cds:CdsError {
            return cds:cdsErrorToHttpResponse(prefetchValidated);
        }

        return prefetchValidated;
    } else {
        string message = string `Can not find a cds service with the name: ${hookId}`;
        int statusCode = 404;
        cds:CdsError cdsError = cds:createCdsError(message, statusCode);
        return cds:cdsErrorToHttpResponse(cdsError);
    }
}

# This method will validate the cds response before sending it back to the client.
#
# + cdsResponse - parameter description.
# + return - return value description.
isolated function postProcessing(cds:CdsResponse|cds:CdsError? cdsResponse) returns http:Response{
    if cdsResponse is cds:CdsError {
        return cds:cdsErrorToHttpResponse(cdsResponse);
    } else {
        cds:CdsResponse|constraint:Error validateResult = constraint:validate(cdsResponse, cds:CdsResponse);
        if validateResult is constraint:Error {
            string message = validateResult.message();
            int statusCode = 400;
            cds:CdsError cdsError = cds:createCdsError(message, statusCode);
            return cds:cdsErrorToHttpResponse(cdsError);
        }

        http:Response response = new ();
        response.setJsonPayload(cdsResponse.toJson());
        return response;
    }
}
