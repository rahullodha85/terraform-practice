package main

import (
	"context"
	"encoding/json"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
    "github.com/aws/aws-sdk-go-v2/service/sts"
    "github.com/aws/aws-sdk-go-v2/config"
//    "github.com/aws/aws-sdk-go-v2/aws"
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

    cfg, err := config.LoadDefaultConfig(context.TODO(),
        config.WithRegion("us-east-1"),
        )
    if err != nil {
        log.Fatalf("unable to load SDK config, %v", err)
    }
    callerIdentityInput := &sts.GetCallerIdentityInput{}
    svc := sts.NewFromConfig(cfg)
    callerIdentityOutput, _ := svc.GetCallerIdentity(ctx, callerIdentityInput)
    log.Printf("account id: %v", *callerIdentityOutput.Account)
    log.Printf("user id: %v", *callerIdentityOutput.UserId)
    log.Printf("arn: %v", *callerIdentityOutput.Arn)
    log.Printf("metadata: %v", callerIdentityOutput.ResultMetadata)

	return events.APIGatewayProxyResponse{
		Body:       "Hello world",
		StatusCode: 200,
	}, nil
}