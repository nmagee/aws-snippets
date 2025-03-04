#!/usr/bin/env python3

import boto3

sns = boto3.client('sns')

response = sns.publish(
    TopicArn="arn:aws:sns:us-east-1:440848399208:cs4740-notification",
    Message="Hey there everybody, how's it going today?",
    Subject="Testing testing"
)
print(response)