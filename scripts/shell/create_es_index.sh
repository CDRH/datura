NAME=$1
ES_URL="localhost:9200"

if [ $NAME ]; then
  curl -XPOST $ES_URL"/"$NAME -d '{
    "settings" : {
      "number_of_shards" : 5,
      "number_of_replicas" : 0
    }
  }
  '
else
  echo "Please enter a name for the index"
fi
