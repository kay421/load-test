#!/bin/bash

set -x

# SERVER_IP=$(curl -q http://169.254.169.254/latest/meta-data/local-ipv4)
SERVER_PORT=1099
RMI_LOCAL_PORT=50000

jmeter -Dserver_port=$SERVER_PORT -Dserver.rmi.localport=$RMI_LOCAL_PORT -Jserver.rmi.ssl.disable=true  -j /dev/stdout -s "$@"