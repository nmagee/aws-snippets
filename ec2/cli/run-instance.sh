#!/bin/bash

# ami - amazon linux 6.1

set -e

aws --profile cs4740 ec2 run-instances \
  --image-id ami-01bc990364452ab3e \
  --instance-type t2.micro \
  --key-name cs4740 \
  --security-group-ids sg-07fd99f31186c2019 \
  --dry-run
