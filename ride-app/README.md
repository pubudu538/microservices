# Ride APP

![alt text](https://raw.githubusercontent.com/pubudu538/microservices/master/ride-app/ride_app.png)

### Prerequisites

1. [Ballerina v1.0](https://v1-0.ballerina.io/)
2. Istio 

### Change the docker registry details

Change registry, username and password in the following three files to push the docker images to the docker registry.

```
src/
├── reservation_service
│   └── reservation_service.bal
├── ride_app_service
│   └── ride_app_service.bal
└── sms_service
    └── sms_service.bal
```

### Build the source 

This will create the docker images, push the docker images to the docker registry and generate relevant K8s artifacts.

```
ballerina build -a
``` 

### Deploy K8s artifacts 

```
kubectl apply -f target/kubernetes/ -R
``` 

### Access the service

```
curl -X POST \
  http://<ingress_gateway_host>:<ingress_gateway_port>/ride \
  -d '{
	"mobile": "+940771234567",
	"pickUpLocation": "Colombo",
	"dropOffLocation": "Panadura",
	"VehicleType": "Budget"
}'
```

You can identify the value of the \<ingress_gateway_host> and \<ingress_gateway_port> as follows.       
For more information, go to the [Istio guide](https://istio.io/docs/tasks/traffic-management/ingress/#determining-the-ingress-ip-and-ports).      
- Use EXTERNAL-IP as the \<ingress_gateway_host> based on the output of the following command.    
`
kubectl get svc istio-ingressgateway -n istio-system
`    

- Use the output of the following command as the \<ingress_gateway_port> value.    
    
```
kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}'
```     
**NOTE:** If you are using a Mac OS and you are running Istio under Docker for desktop’s built-in Kubernetes, the \<ingress_gateway_port> value will always be port 80.      
