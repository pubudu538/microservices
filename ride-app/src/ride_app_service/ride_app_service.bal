import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/kubernetes;
import ballerina/istio;

@istio:Gateway {}
@istio:VirtualService {}
@kubernetes:Service {
    name: "ride-app-service"
}
@kubernetes:Deployment {
    registry: "pubudu",
    username: "pubudu",
    password: "xxx"
}
service ride on new http:Listener(9070) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }

    resource function getRide(http:Caller caller, http:Request req) {

        var payload = req.getJsonPayload();
        http:Response res = new;
        if (payload is json) {
            

            string pickUpLocation = payload.pickUpLocation.toString();
            string dropOffLocation = payload.dropOffLocation.toString();
            string mobileNumber = payload.mobile.toString();
            string vehicleType = payload.vehicleType.toString();

             json rideInfo = {
            	pickUpLocation: pickUpLocation,
                dropOffLocation: dropOffLocation,
                mobileNumber: mobileNumber,
                vehicleType: vehicleType            
        	};

        	json|error bookingResponse = reserveVehicle(<@untainted> rideInfo);

        	if (bookingResponse is json) {

        		json smsInfo = {
            		mobile: mobileNumber,
            		rideInfo: bookingResponse
        		};

        		boolean smsSuccessful = smsUser(<@untainted> smsInfo);
            }

            json successMessage = {message: "Your ride is on the way", status: "success"};
            res.setJsonPayload(<@untainted> successMessage);

            io:println(successMessage);
        } else {
            res.statusCode = 500;
            string message =  "Unable to book a ride to your request.";
            json errorMessage = { message: message, status: "fail" };
            res.setJsonPayload(<@untainted> errorMessage);
            io:println(errorMessage);
        }
        var result = caller->respond(res);
        if (result is error) {
           log:printError("Error in responding", result);
        }
    }
}


function smsUser(json smsInfo) returns boolean {

    string endpoint = "http://sms-service:9090";
    string path = "/sms";

    http:Client clientEP = new(endpoint);
    var response = clientEP->post(path, smsInfo);

    if (response is http:Response) {
        json|error msg = response.getJsonPayload();

        if (msg is json) {
            string status = msg.status.toString();

            if ("success" == status) {
            	return true;
            }
            return false;
        }
    }
    return false;   
}


function reserveVehicle(json rideInfo) returns json|error {

    string endpoint = "http://reservation-service:9080";
    string path = "/reserve";

    http:Client clientEP = new(endpoint);
    var response = clientEP->post(path, rideInfo);

    if (response is http:Response) {
        json|error msg = response.getJsonPayload();

        return <@tained> msg;
    }
    return;   
}







