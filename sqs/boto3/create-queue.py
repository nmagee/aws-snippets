#!/usr/local/bin/python3

import boto3

sqs = boto3.client('sqs')

response = sqs.create_queue(
    QueueName='video-queue'
)
print(response)