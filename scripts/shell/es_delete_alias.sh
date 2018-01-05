#!/usr/bin/env bash

NAME=$1
URL="localhost:9200/_all/_alias/"$NAME

curl -XDELETE $URL'?pretty'
