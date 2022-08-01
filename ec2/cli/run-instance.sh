#!/bin/bash

set -e

aws ec2 run-instances \
  --image-id ami-087c17d1fe0178315 \
  --instance-type t2.micro \
  --key-name cs4740 \
  --security-group-ids sg-07fd99f31186c2019 \
  --dry-run
