# aws-snippets

Sample AWS CloudFormation/CLI/boto3 templates for SDS.

- Cloudformation - infrastructure templating language for repeatable deployments.
- CLI - the AWS CLI, a command-line interface to the AWS cloud.
- `boto3` - the AWS Python3 SDK for programmatic support.

## Resources

- [api-gateway/](api-gateway/) — A Chalice-based demo for creating and deploying API Gateway endpoints with Lambda backends.
- [dynamodb/](dynamodb/) — CloudFormation templates for provisioning DynamoDB tables.
- [ec2/](ec2/) — EC2 instance examples spanning CloudFormation templates, CLI launch scripts, and boto3 helpers for describing/launching instances.
- [kinesis/](kinesis/) — CloudFormation template for a Kinesis Data Stream wired to a Lambda consumer.
- [lambda/](lambda/) — Python Lambda function examples including an API demo and a compliance-evaluation function.
- [s3/](s3/) — S3 bucket creation via CloudFormation (including CloudFront-backed websites) and boto3 scripts for upload, download, and listing.
- [secrets/](secrets/) — A boto3 script for fetching secrets from AWS Secrets Manager.
- [sns/](sns/) — SNS publishing via boto3 and CloudFormation templates for topic creation.
- [sqs/](sqs/) — SQS queue management through CloudFormation templates and a full set of boto3 scripts for creating, sending, receiving, and purging queues.
- [vpc/](vpc/) — CloudFormation templates for VPCs with public/private subnets, NAT gateways, and embedded EC2 instances.
