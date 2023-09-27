package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-lambda-go/lambdacontext"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/magdyamr542/terraform-aws/pkg/api"
)

const (
	Bucket = "aws-s3-bucket-app-bucket-destination-testing"
)

func HandleQueueMessage(ctx context.Context, message events.SQSEvent) error {
	lc, ok := lambdacontext.FromContext(ctx)
	if !ok {
		return fmt.Errorf("no lambda context")
	}

	log.Printf("Got sqs event. [function_arn=%q]\n", lc.InvokedFunctionArn)

	// Init SQS and get the Url of the queue.
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))

	s3Svc := s3.New(sess)

	for _, record := range message.Records {

		log.Printf("Queue event. [id=%s] [eventSource=%s] [payload=%+v]\n",
			record.MessageId, record.EventSource, record.Body)

		var payload api.QueuePayload
		if err := json.Unmarshal([]byte(record.Body), &payload); err != nil {
			return fmt.Errorf("input isn't in the correct format: %v", err)
		}

		payloadBytes, err := json.Marshal(payload)
		if err != nil {
			return fmt.Errorf("can't Marshal queue payload to bytes: %v", err)
		}

		// e.g 2006-01-02T15:04:05Z07:00
		key := time.Now().Format(time.RFC3339) + ".json"
		if _, err := s3Svc.PutObject(&s3.PutObjectInput{
			Key:    aws.String(key),
			Bucket: aws.String(Bucket),
			Body:   bytes.NewReader(payloadBytes),
		}); err != nil {
			return fmt.Errorf("can't put object to bucket: %v", err)
		}

		log.Printf("Operation %q. Result %d\n", payload.Operation, payload.Result)
	}

	return nil
}

func main() {
	lambda.Start(HandleQueueMessage)
}
