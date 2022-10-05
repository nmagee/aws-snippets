#!/usr/local/bin/python3

import boto3
import botocore
from botocore.exceptions import ClientError

sqs = boto3.client('sqs')
qurl = "https://sqs.us-east-1.amazonaws.com/440848399208/video-queue"

# Send a message to the queue
def send_message(qurl, message):
    try:
        response = sqs.send_message(
            QueueUrl=qurl,
            MessageBody=message
        )
        print(response)
    except ClientError as e:
        print(e)

message = "Hello there queuers!"
send_message(qurl, message)