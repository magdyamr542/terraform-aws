### Pipeline:

```mermaid
flowchart TB
   Client[Client] --Upload JSON file to <strong>Bucket 1</strong>--> S3
   Client ~~~|"Can be any client.\nWill be done with the AWS cli."| Client
   S3[S3\nBucket 1] --The bucket fires an event <strong>s3:ObjectCreated</strong> --> Lambda1
   Lambda1[Lambda 1] --1. Read from <strong>Bucket 1</strong>.\n2. Put payload in the queue--> SQS
   SQS --The queue triggers <strong>Lambda 2</strong> with an event--> Lambda_2
   Lambda_2[Lambda 2] --Put the message in <strong>Bucket 2</strong>.--> Bucket_2
   Bucket_2[S3\nBucket 2] --> END

```

The infrastructure should be reproducible. Terraform is used to provision the needed components in AWS.

All components should have the needed permissions to do their job. Example: S3 needs to have permissions to trigger the lambda. Lambda should have permissions to put messages in the queue etc.
