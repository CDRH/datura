NAME=$1
URL="localhost:9200/"$NAME

curl -XPOST $URL'/_delete_by_query' -H 'Content-Type: application/json' -d '{
    "query" : { 
        "match_all" : {}
    }
}'
