### Chat application (Websockets with ApiGateway + Dynamodb)

```mermaid
flowchart TB
   Client[Client] -- Connects --> APIGateway[API Gateway]
   Client ~~~|"Connect to the provided aws ws url with wscat"| Client

   Client[Client] -- Disconnects --> APIGateway[API Gateway]

   Client[Client] -- Sends message --> APIGateway[API Gateway]

   APIGateway -- Invoke OnConnect Lambda --> Lambda_onconnect[Lambda OnConnect]

   APIGateway -- Invoke OnDisconnect Lambda --> Lambda_ondisconnect[Lambda OnDisconnect]

   APIGateway --Invoke OnMessage Lambda --> Lambda_onmessage[Lambda OnMessage]

   Lambda_onconnect -- Save connection id in dynamo --> DynamoDb
   Lambda_ondisconnect -- Remove connection id from dynamo --> DynamoDb
   Lambda_onmessage -- Deliver message to all connected connections\n (Use the ids saved in Dynamo ) --> DynamoDb
   DynamoDb --> End
```

The infrastructure should be reproducible. Terraform is used to provision the needed components in AWS.

All components should have the needed permissions to do their job. Example: S3 needs to have permissions to trigger the lambda. Lambda should have permissions to put messages in the queue etc.
