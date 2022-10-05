#!/usr/local/bin/python3

import boto3

sqs = boto3.client('sqs')
qurl = "https://sqs.us-east-1.amazonaws.com/440848399208/video-queue"

response = sqs.get_queue_attributes(
    QueueUrl=qurl,
    AttributeNames=['All']
)
# print(response)
MESSAGES = response['Attributes']['ApproximateNumberOfMessages']
print(MESSAGES)