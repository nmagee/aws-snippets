# AWS Config Compliance

This POC solution uses AWS Config to monitor changes in EC2 Security Groups. All changes
to SGs trigger a Lambda function to evaluate its security compliance. When an SG
is given an ingress rule that exposes port 22 to `0.0.0.0/0` the Lambda performs three tasks:

1. Remediates the security vulnerability by revoking the new ingress rule.
2. Logs the violation into a DynamoDB table.
3. Alerts engineering via SNS notification.


