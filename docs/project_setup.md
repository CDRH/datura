## Set up New API Project

Please bear with me, this is the lightning documentation version.

### Step 1:  Create a new project directory

Please refer to the documentation on the required file structure of projects for more information about how to set up files and scripts.  Move your data files (currently TEI only) to the project. Copy an existing `public.yml` config file and edit anything specific to the project.

```
default:
    project_desc: Willa Cather's correspondence
    solr_core: cather
    es_type: cather
    shortname: cather
```

You may need more or fewer fields.  If you will need different behavior locally vs on a server, then please use the `private.yml` file instead, which will not be version controlled.

### Step 2: Prepare Elasticsearch Index

**WARNING** currently the manage schema script is hardcoded with "test1" as an index name, which will need to change in the future.  This is just a very basic setup step to get other devs going, so bear that in mind.

Create a new index, if one does not exist that you will be using.

```
./scripts/shell/es_create_index.sh name_of_index
```

Assuming this is successful, now we will need to set up a schema for it.  Even if an index with this name exists, since you will be pushing to a specific TYPE you still need to run this mapping.

```
# Note: assumes test1 as index name
ruby scripts/ruby/es_set_schema.rb name_of_project
```

You may run the above as many times as you wish, as long as you have not already put items in the index which will conflict with the fieldtypes.

### Step 3: Populate the Index

Now is the fun part when you get to run your data.  Information about how to run the specifics of the posting script exist in the main readme, so I will not be covering that today.  Instead, simply run the following command to get everything in there:

```
# -x es selects elasticsearch only
# -o requests it to write files so you can inspect the json results

ruby scripts/ruby/es_post.rb name_of_project -x es -o
```

### Step 4: Customize the Information

Please take a look at the `projects/example` directory.  In here, you will find a number of files that are very useful.  When it comes to customizing your project, the most important of these will be the `public.yml` and `private.yml` config files and the `scripts/tei_to_es.rb` file.

The config files are fairly straightforward.  If you put things in the private config file, they will not be transferred to other users or server.  This means it is a great place to put sensitive information like the elasticsearch location.  It is also a great place for information which changes depending on its environment, like if you use localhost:9200 on your machine but a server uses cdrhdev1.unl.edu/es_test.

Anything in the public configuration will be tracked.  This means you should not put sensitive information in this file. Most of your project's setup can probably be done in the `public.yml` file, like the `es_type`, project description, and other information which you will want other people downloading the repo to have.

Please look at the example project's config files for a list of variables which can be overridden.  You may also add entire new variables to use later in fields which the project may need to add or customize.

For information about customizing and adding fields, please refer to `docs/tei_to_es.rb`
