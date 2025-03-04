import boto3
import json

s3 = boto3.client('s3')

response = s3.list_buckets()

for x in response['Buckets']:
    print(x['Name'])

