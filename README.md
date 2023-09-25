### Pipeline:

```mermaid
flowchart TB
   Client[Client] --Upload JSON file--> S3[S3]
   Client ~~~|"Can be any client.\nWill be done with the AWS cli."| Client
   S3[S3] --Trigger with event--> Lambda[Lambda]
   Lambda[Lambda 1] --Put payload in the queue--> SQS[SQS]
   Lambda_2[Lambda 2] --Fetch from the queue--> SQS
   Lambda_2[Lambda 2] --Echo the message.\n This can be observed in the logs--> End

```

The infrastructure should be reproducible. Terraform is used to provision the needed components in AWS.

All components should have the needed permissions to do their job. Example: S3 needs to have permissions to trigger the lambda. Lambda should have permissions to put messages in the queue etc.
