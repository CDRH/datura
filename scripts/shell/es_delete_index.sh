NAME=$1
URL="localhost:9200/"$NAME

curl -XDELETE $URL'?pretty=true'
