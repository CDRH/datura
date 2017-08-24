NAME=$1
FULL_URL="localhost:9200/"$NAME

curl -XPUT $FULL_URL"?pretty&pretty"
curl -XGET 'localhost:9200/_cat/indices?v&pretty'
