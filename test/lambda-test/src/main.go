package main

import (
	"context"
	"encoding/json"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	log.Printf("Start Lambda")
	lambda.Start(Handler)
}

type MyEvent map[string]interface{}

func Handler(ctx context.Context, event MyEvent) (events.APIGatewayProxyResponse, error) {
	// stdout and stderr are sent to AWS CloudWatch Logs
	for k, v := range event{
		log.Printf("Key: %s, Value: %s", k, v)
	}
	eventString, _ := json.Marshal(event)
	log.Printf("Event String: %s", eventString)
	return events.APIGatewayProxyResponse{
		Body:       "Hello world",
		StatusCode: 200,
	}, nil
}