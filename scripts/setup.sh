#!/bin/bash

echo "Waiting for startup.."
until curl http://mongo:28017/serverStatus\?text\=1 2>&1 | grep uptime | head -1; do
  printf '.'
  sleep 1
done

echo curl http://mongo:28017/serverStatus\?text\=1 2>&1 | grep uptime | head -1
echo "Started.."


echo SETUP.sh time now: `date +"%T" `
mongo --host mongo:27017 <<EOF
    rs.initiate();
EOF