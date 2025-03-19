#!/usr/local/bin/python3

import boto3
import botocore
from botocore.exceptions import ClientError

sqs = boto3.client('sqs')
# qurl = "https://sqs.us-east-1.amazonaws.com/440848399208/video-queue"
qurl = "https://sqs.us-east-1.amazonaws.com/379111353384/ds2002"

# Send a message to the queue
def send_message(qurl, message):
    try:
        response = sqs.send_message(
            QueueUrl=qurl,
            MessageBody=message,
            MessageAttributes={
                'project': {
                    'StringValue': 'research',
                    'DataType': 'String'
                }
            }
        )
        print(response)
        status = response['ResponseMetadata']['HTTPStatusCode']
        if (status == 200):
            print("200 OK")
        else:
            print("Not-OK")
    except ClientError as e:
        print(e)

message = "Hello there queuers!"
send_message(qurl, message)
