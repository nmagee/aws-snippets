#!/usr/bin/env python3

import boto3

sqs = boto3.client('sqs')

def check_message_count():
    response = sqs.get_queue_attributes(
        QueueUrl='https://queue.amazonaws.com/440848399208/demo-queue',
        AttributeNames=[
          'All',
        ]
    )
    anom = response['Attributes']['ApproximateNumberOfMessages']
    if ( int(anom) >=1 ):
      print("Count: " + anom + " Greater than or = to 1!")
      get_message()
    else:
      print("No messages available.")


def delete_message(handle):
    response = sqs.delete_message(
        QueueUrl='https://queue.amazonaws.com/440848399208/demo-queue',
        ReceiptHandle=handle
    )

def get_message():
    try:
      response = sqs.receive_message(
        QueueUrl='https://queue.amazonaws.com/440848399208/demo-queue',
        AttributeNames=['All'],
        MessageAttributeNames=[
            'project',
        ],
        MaxNumberOfMessages=1,
        VisibilityTimeout=30,
        WaitTimeSeconds=20,
      )['Messages'][0]
      messageid = response['MessageId']
      handle = response['ReceiptHandle']
      project = response['MessageAttributes']['project']['StringValue']
      print("MessageID: " + messageid)
      # print("Handle: " + handle)
      print("Project: " + project)
      print(response)
      delete_message(handle)
    except:
        print("Nothing to see here")

check_message_count()
