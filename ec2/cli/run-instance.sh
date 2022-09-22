#!/bin/bash

set -e

aws --profile cs4740 ec2 run-instances \
  --image-id ami-05fa00d4c63e32376 \
  --instance-type t2.micro \
  --key-name cs4740 \
  --security-group-ids sg-07fd99f31186c2019 \
  --dry-run
