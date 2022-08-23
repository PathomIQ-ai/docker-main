#!/bin/bash

# login
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 766225006095.dkr.ecr.us-west-2.amazonaws.com

# build image with updates
docker build -t pathomiq/pytorch-1.0 /home/ec2-user/docker-main/

# add names
docker tag pathomiq/pytorch-1.0:test 766225006095.dkr.ecr.us-west-2.amazonaws.com/pathomiq/pytorch-1.0:test

# upload and sync with aws
docker push 766225006095.dkr.ecr.us-west-2.amazonaws.com/pathomiq/pytorch-1.0:test


