#!/usr/bin/env python3

import boto3

sqs = boto3.client('sqs')

response = sqs.create_queue(
    QueueName='demo-queue',
)
print(response)
