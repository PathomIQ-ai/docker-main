#!/bin/bash

aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 766225006095.dkr.ecr.us-west-2.amazonaws.com
docker build -t pathomiq/pytorch-1.0 /home/ec2-user/docker-main/
docker tag pathomiq/pytorch-1.0:latest 766225006095.dkr.ecr.us-west-2.amazonaws.com/pathomiq/pytorch-1.0:latest
docker push 766225006095.dkr.ecr.us-west-2.amazonaws.com/pathomiq/pytorch-1.0:latest


