#!/usr/bin/env python3

import boto3

sqs = boto3.client('sqs')

response = sqs.delete_queue(
    QueueUrl='https://queue.amazonaws.com/440848399208/demo-queue'
)
print(response)
