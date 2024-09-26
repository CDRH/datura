## Installation

### Solr

TODO

### Elasticsearch

Download Elasticsearch 8 [here](https://www.elastic.co/downloads/elasticsearch).

### Apache Permissions

Assuming that you place this collection in your web tree, you will need to take care to protect any sensitive information you place it in that you do not want to be accessible through the browser (copywritten material, drafts, passwords, etc). To protect the configuration files that contain information about your solr instance, you should put these lines in your main apache configuration file. If you have an older version of Apache, you may need to specify `Order deny,allow` and `Deny from all` instead of using `Require all denied`.

```
#
# Prevent private.yml files that might be in the webtree from being viewable
#
<FilesMatch ".*private\.yml">
    Require all denied
</FilesMatch>
```

Otherwise, you should not need to do anything with apache assuming that you already had it set up with a webtree.
