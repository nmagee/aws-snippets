#!/usr/bin/env python3

# aws ec2 run-instances \
#   --image-id ami-087c17d1fe0178315 \
#   --instance-type t2.micro \
#   --key-name cs4740 \
#   --security-group-ids sg-07fd99f31186c2019 \
#   --dry-run

import logging
import boto3
from botocore.exceptions import ClientError

ec2 = boto3.client('ec2')

def run_instance():
  try:
    response = ec2.run_instances(
      MinCount = 1,
      MaxCount = 1,
      ImageId = 'ami-087c17d1fe0178315',
      InstanceType = 't2.micro',
      KeyName = 'cs4740',
      SecurityGroupIds = ['sg-07fd99f31186c2019'],
      DryRun = False
    )
    print(response)
  except ClientError as e:
    logging.error(e)
    print(e)
    return False
  return True

run_instance()
