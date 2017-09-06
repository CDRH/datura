# mimic this structure to send a single file at once
# POST
#  path to elasticsearch (localhost:9200)
#  index name (test_)
#  collection name / _type (type1)
#  id of item (1)
#  put in JSON for item

curl -XPOST 'localhost:9200/test/type1/1?pretty'  -d'
{
    "stuff": "something"
}
'
