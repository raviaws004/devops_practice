#!/bin/bash

NUMBER1=$1
NUMBER2=$2
NUMBER1=$3
NUMBER2=$4

SUM=$(($NUMBER1+$NUMBER2))

echo "Total:: $SUM"
echo "How many arguments passed: $#"
echo "All arguments : $@"