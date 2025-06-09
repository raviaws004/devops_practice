#!/bin/bash

MONGODB_HOST=172.31.36.0
LOGFILE="/tmp/mongo-test.log"

echo "Running mongosh..." >> $LOGFILE

mongosh --host $MONGODB_HOST </app/schema/catalogue.js >> $LOGFILE 2>&1
RETVAL=$?

if [ $RETVAL -ne 0 ]; then
  echo "❌ ERROR: Loading data into MongoDB failed" >> $LOGFILE
  echo -e "❌ ERROR: Loading data into MongoDB failed"
else
  echo "✅ SUCCESS: Data loaded into MongoDB" >> $LOGFILE
  echo -e "✅ SUCCESS: Data loaded into MongoDB"
fi
