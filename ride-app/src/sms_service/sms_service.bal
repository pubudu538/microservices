import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/kubernetes;

@kubernetes:Service {
    name: "sms-service"
}
@kubernetes:Deployment {
    registry: "pubudu",
    username: "pubudu",
    password: "XXXX",
    push: true
}
service sms on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }

    resource function smsUser(http:Caller caller, http:Request req) {

        var payload = req.getJsonPayload();
        http:Response res = new;
        if (payload is json) {
            
            string smsMessage = "SMS sent to the client";
            string mobileNumber = payload.mobile.toString();
            string message =  smsMessage.concat(" - ", mobileNumber);
            json successMessage = {message: message, status: "success"};
            res.setJsonPayload(<@untainted> successMessage);
            io:println(successMessage);
        } else {
            res.statusCode = 500;
            string message =  "Failed to SMS.";
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
