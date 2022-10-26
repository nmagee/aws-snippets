import json
import boto3
from datetime import datetime


# Use as a starter/stub -- can and should be modified for production
FORMAT = '%Y%m%d-%H:%M:%S'
now = datetime.now().strftime(FORMAT)

def lambda_handler(event, context):
    invoking_event = json.loads(event['invokingEvent'])
    resourceId = invoking_event['configurationItem']['resourceId']
    captureTime = invoking_event['configurationItem']['configurationItemCaptureTime']
    for item in invoking_event['configurationItem']['configuration']['ipPermissions']:
        toPort = item['toPort']
        secgrp = invoking_event['configurationItem']['configuration']['groupId']
        if toPort == 22:
            for cidr in item['ipv4Ranges']:
                bcidr = cidr['cidrIp']
                if (bcidr == '0.0.0.0/0' or bcidr == '::/0'):
                    update_config(resourceId, 'NON_COMPLIANT', captureTime, event)
                    arn = invoking_event['configurationItem']['ARN']
                    print("CIDR violation found - attempting to remediate")
                    message = "Port 22 violation "
                    sendmsg(arn,message)
                    remediate(secgrp)
                    dbinsert(secgrp, '1')
                    update_config(resourceId, 'COMPLIANT', captureTime, event)
                    message = "Port 22 violation REMEDIATED "
                    sendmsg(arn,message)
        else:
            print("SSH ingress compliance met")
            update_config(resourceId, 'COMPLIANT', captureTime, event)
                  
def remediate(secgrp):
    print("Remediating SSH violation for: " + secgrp)
    ec2client = boto3.client('ec2')
    update = ec2client.revoke_security_group_ingress(
        GroupId=secgrp,
        IpPermissions=[
            {
                'FromPort': 22,
                'IpProtocol': 'TCP',
                'IpRanges': [
                    {
                        'CidrIp': '0.0.0.0/0'
                    },
                ],
                'Ipv6Ranges': [
                    {
                        'CidrIpv6': '::/0'
                    },
                ],
                'ToPort': 22
            },
        ]
    )
    print("SSH Violation remediated for: " + secgrp)
    
def sendmsg(arn,message):
    client = boto3.client('sns')
    response = client.publish(
        TopicArn='arn:aws:sns:us-east-1:440848399208:SysAdmin',
        Message = str(message) + "\n\n" + str(arn),
        Subject ='CIDR Violation'
    )
    
def dbinsert(secgrp, status):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('cidr-status')
    table.put_item(
    Item={
        'security-group': secgrp,
        'status': status,
        'when': now,
    }
)
    
def update_config(resourceId, compliance_type, captureTime, event):
    result_token = "No token found."
    if "resultToken" in event:
        result_token = event["resultToken"]
        config = boto3.client("config")
        config.put_evaluations(
            Evaluations=[
                {
                    "ComplianceResourceType": "AWS::EC2::SecurityGroup",
                    "ComplianceResourceId": resourceId,
                    "ComplianceType": compliance_type,
                    "Annotation": "SSH port 22 configuration",
                    "OrderingTimestamp": captureTime
                },
            ],
        ResultToken=result_token
    )
