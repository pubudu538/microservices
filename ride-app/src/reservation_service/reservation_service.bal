import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/kubernetes;
import ballerina/math;


@kubernetes:Service {
    name: "reservation-service"
}
@kubernetes:Deployment {
    registry: "pubudu",
    username: "pubudu",
    password: "XXXX",
    push: true
}
service reserve on new http:Listener(9080) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }

    resource function reserveVehicle(http:Caller caller, http:Request req) {

        var payload = req.getJsonPayload();
        http:Response res = new;
        if (payload is json) {

            string number = math:randomInRange(1000, 9999).toString();
            string letterValue = "ABC";
            string vehicleNumber = letterValue.concat("-", number);

            json bookingDetails = {
                status: "success",
                vehicleNumber: vehicleNumber,
                vehicleType: "car",
                driverName: "John Doe",
                driverMobile: "+940777588588",
                bookingRef: number
            };

            res.setJsonPayload(<@untainted> bookingDetails);

            string successMessage = "Your booking has been confirmed. Booking number is";
            string outputMessage = successMessage.concat(" ", number);

            io:println(outputMessage);
        } else {
            res.statusCode = 500;
            string message =  "Failed to reserve a vehicle.";
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








