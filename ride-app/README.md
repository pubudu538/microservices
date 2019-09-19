# Ride APP

### Prerequisites

1. [Ballerina v1.0](https://v1-0.ballerina.io/)

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