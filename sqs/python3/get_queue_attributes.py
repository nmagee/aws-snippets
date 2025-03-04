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
    else:
      print("No messages available.")
    print(response)

check_message_count()
