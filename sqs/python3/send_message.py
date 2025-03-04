#!/usr/bin/env python3

import boto3

sqs = boto3.client('sqs')

response = sqs.send_message(
    QueueUrl='https://queue.amazonaws.com/440848399208/demo-queue',
    MessageBody='body goes here 12345',
    MessageAttributes={
        'project': {
            'StringValue': 'research',
            'DataType': 'String'
        }
    }
)
print(response)
