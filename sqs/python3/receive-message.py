#!/usr/local/bin/python3

import boto3
import botocore
from botocore.exceptions import ClientError

sqs = boto3.client('sqs')
qurl = "https://sqs.us-east-1.amazonaws.com/440848399208/video-queue"

def check_message_count(qurl):
    try:
        response = sqs.get_queue_attributes(
            QueueUrl=qurl,
            AttributeNames=['ApproximateNumberOfMessages']
        )
        MSGCOUNT = int(response["Attributes"]["ApproximateNumberOfMessages"])
        print(MSGCOUNT)
        if (MSGCOUNT > 0):
            receive_message(qurl)
        else:
            print("There are no messages in the queue.")
    except ClientError as e:
        print(e)

def delete_message(qurl, handle):
    try:
        response = sqs.delete_message(
            QueueUrl=qurl,
            ReceiptHandle=handle
        )
        # print(response)
    except ClientError as e:
        print(e)

def receive_message(qurl):
    try:
        response = sqs.receive_message(
            QueueUrl=qurl,
            MaxNumberOfMessages=1,
        )
        # print(response)
        MSGBODY = response["Messages"][0]["Body"]
        print(MSGBODY)
        HANDLE = response["Messages"][0]["ReceiptHandle"]
        # print(HANDLE)
        delete_message(qurl, HANDLE)
    except ClientError as e:
        print(e)

check_message_count(qurl)