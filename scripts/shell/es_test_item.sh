# mimic this structure to send a single file at once
# POST
#  path to elasticsearch (localhost:9200)
#  index name (test_)
#  id of item (1)
#  put in JSON for item

# DO NOT RUN THIS AGAINST ANY INDEXES YOU CARE ABOUT
# IT WILL CREATE A NEW KEYWORD FIELD MAPPING

curl -XPOST 'localhost:9200/test/_doc/1?pretty=true' -H 'Content-Type: application/json' -d'
{
    "stuff": "something"
}
'
