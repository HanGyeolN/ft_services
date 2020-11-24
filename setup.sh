#!/bin/sh

sftp -i ./srcs/aws_key.pem ubuntu@52.78.194.201 "put ./srcs"

ssh -i ./srcs/aws_key.pem ubuntu@52.78.194.201 "./srcs/setup.sh"
