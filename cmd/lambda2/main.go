package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-lambda-go/lambdacontext"
	"github.com/magdyamr542/terraform-aws/pkg/api"
)

func HandleQueueMessage(ctx context.Context, message events.SQSEvent) error {
	lc, ok := lambdacontext.FromContext(ctx)
	if !ok {
		return fmt.Errorf("no lambda context")
	}

	log.Printf("Got sqs event. [function_arn=%q]\n", lc.InvokedFunctionArn)

	for _, record := range message.Records {

		log.Printf("Queue event. [id=%s] [eventSource=%s] [payload=%+v]\n",
			record.MessageId, record.EventSource, record.Body)

		var payload api.QueuePayload
		if err := json.Unmarshal([]byte(record.Body), &payload); err != nil {
			return fmt.Errorf("input isn't in the correct format: %v", err)
		}

		log.Printf("Operation %q. Result %d\n", payload.Operation, payload.Result)
	}

	return nil
}

func main() {
	lambda.Start(HandleQueueMessage)
}
