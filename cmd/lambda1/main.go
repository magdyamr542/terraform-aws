package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/sqs"
	"github.com/magdyamr542/terraform-aws/pkg/api"
)

const (
	Queue = "app_queue"
	App   = "lambda1"
)

func HandleLambdaEvent(event events.S3Event) error {

	// Init SQS and get the Url of the queue.
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))

	sqsSvc := sqs.New(sess)
	queueUrl, err := sqsSvc.GetQueueUrl(&sqs.GetQueueUrlInput{
		QueueName: aws.String(Queue),
	})
	if err != nil {
		return fmt.Errorf("can't get the url of the queue %s", Queue)
	}

	s3Svc := s3.New(sess)
	for _, record := range event.Records {
		record := record

		log.Printf("event data: %+v\n", event)

		object, err := s3Svc.GetObject(&s3.GetObjectInput{
			Bucket: &record.S3.Bucket.Name,
			Key:    &record.S3.Object.Key,
		})
		if err != nil {
			return err
		}
		objectBytes, err := io.ReadAll(object.Body)
		object.Body.Close()
		if err != nil {
			return err
		}

		var s3Content api.S3Content
		if err := json.Unmarshal(objectBytes, &s3Content); err != nil {
			return err
		}

		sqsPayload, err := getPayload(s3Content)
		if err != nil {
			return err
		}

		sqsPayloadBytes, err := json.Marshal(sqsPayload)
		if err != nil {
			return err
		}

		// Send the message to the queue.
		if _, err := sqsSvc.SendMessage(&sqs.SendMessageInput{
			MessageAttributes: map[string]*sqs.MessageAttributeValue{
				"Sender": {
					DataType:    aws.String("String"),
					StringValue: aws.String(App),
				},
			},
			MessageBody: aws.String(string(sqsPayloadBytes)),
			QueueUrl:    queueUrl.QueueUrl,
		}); err != nil {
			return fmt.Errorf("can't send message to the queue: %v", err)
		}

	}

	return nil
}

func getPayload(event api.S3Content) (api.QueuePayload, error) {
	var payload api.QueuePayload

	switch event.Operation {
	case api.Add:
		payload = api.QueuePayload{Result: event.Operator1 + event.Operator2, Operation: event.String()}

	case api.Subtract:
		payload = api.QueuePayload{Result: event.Operator1 - event.Operator2, Operation: event.String()}

	case api.Multiply:
		payload = api.QueuePayload{Result: event.Operator1 * event.Operator2, Operation: event.String()}

	case api.Divide:
		if event.Operator2 == 0 {
			return payload, fmt.Errorf("can't divide by 0")
		}
		payload = api.QueuePayload{Result: event.Operator1 / event.Operator2, Operation: event.String()}

	default:
		return payload, fmt.Errorf("invalid operation")
	}
	return payload, nil
}

func main() {
	lambda.Start(HandleLambdaEvent)
}
