#!/bin/bash

pip install 'elastic2-doc-manager[elastic5]'
pip install 'mongo-connector[elastic5]'

printf "\n\nWaiting for MongoDB to start\n"
until curl http://mongo:28017/serverStatus\?text\=1 2>&1 | grep uptime | head -1; do
  printf '.'
  sleep 1
done
echo "MongoDB has started!"

echo "\n\nStarting mongo-connector.."
mongo-connector --auto-commit-interval=5 -m mongo:27017 -t elasticsearch:9200 -d elastic2_doc_manager --stdout