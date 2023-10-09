### Pipeline:

```mermaid
flowchart TB
   Client[Client] --Upload JSON file--> S3
   Client ~~~|"Can be any client.\nWill be done with the AWS cli."| Client
   S3[S3\nBucket 1] --Fire event and invoice lambda 1--> Lambda
   Lambda[Lambda 1] --Put payload in queue--> SQS
   SQS --Invoke lambda 2 with messages from the queue--> Lambda_2
   Lambda_2[Lambda 2] --Put queue payload in Bucket 2 as a JSON file--> S3_2
   S3_2[S3\nBucket 2] -->End
```

The infrastructure should be reproducible. Terraform is used to provision the needed components in AWS.

All components should have the needed permissions to do their job. Example: S3 needs to have permissions to trigger the lambda. Lambda should have permissions to put messages in the queue etc.
