NAME=$1
URL="localhost:9200/"$NAME

curl -XPOST $URL'/_delete_by_query' -d '{
    "query" : { 
        "match_all" : {}
    }
}'