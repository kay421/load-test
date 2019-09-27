#!/bin/bash -e

docker build --tag="jmeter-slave:latest" -f Dockerfile_slave .
docker build --tag="jmeter-master:latest" -f Dockerfile_master .