import boto3

client = boto3.client('ec2')

response = client.run_instances(
  ImageId='ami-02354e95b39ca8dec',
  InstanceType='t2.micro',
  KeyName='nem2p-cs4740',
  SecurityGroupIds=[
    'sg-0c5cf2cca6833f090',
  ],
  # SubnetId='subnet-b39b21c5',
  DryRun=False,
  MinCount=1,
  MaxCount=1,
  InstanceInitiatedShutdownBehavior='terminate',
  TagSpecifications=[
    {
      'ResourceType': 'instance',
      'Tags': [
        {
          'Key': 'Name',
          'Value': 'boto3-created-instance'
        },
      ]
    },
  ]
)

print(response)
