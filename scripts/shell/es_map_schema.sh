curl -sS -XPUT 'http://localhost:9200/test1/_mapping/all?update_all_types' -d'
{
  "properties": {
    "cdrh-identifier": {
      "type": "keyword"
    },
    "dc-identifier": {
      "type": "keyword"
    },
    "cdrh-shortname": {
      "type": "keyword"
    },
    "cdrh-project": {
      "type": "keyword"
    },
    "cdrh-uri": {
      "type": "keyword"
    },
    "cdrh-uri_data": {
      "type": "keyword"
    },
    "cdrh-uri_html": {
      "type": "keyword"
    },
    "cdrh-data_type": {
      "type": "keyword"
    },
    "cdrh-fig_location": {
      "type": "keyword"
    },
    "cdrh-image_id": {
      "type": "keyword"
    },
    "dc-title": {
      "type": "keyword"
    },
  }
}'

curl 'localhost:9200/test1/_mapping?pretty'

# "person" : {
#         "type" : "nested",
#         "properties" : {
#           "id" : { "type" : "string" },
#           "name" : { "type" : "string" },
#           "name_keyword" : { 
#             "type" : "string",
#             "index" : "not_analyzed"
#           },
#           "role" : {
#             "type" : "string",
#             "index" : "not_analyzed"
#           }
#         }
#       },