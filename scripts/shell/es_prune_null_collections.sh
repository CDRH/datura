#!/usr/bin/env bash

# specify index name
# this script deletes all documents which do not have a collection name
# (these documents do not appear in the API at /collections, but are listed at /items)

NAME=$1
URL="localhost:9200/${NAME}/_delete_by_query?pretty"

curl -X POST $URL -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must_not" : {
        "exists" : {
          "field" : "collection"
        }
      }
    }
  }
}
'
