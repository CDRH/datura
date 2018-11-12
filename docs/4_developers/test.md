## Writing and Running Tests

TODO the below are outdated

### Running Tests

```
rake test
```

### Writing Tests for collections

As you are creating a collection, you may want to creates some tests to make sure that tricky documents and edgecases are doing what you think they are doing.

You can create any number of tests for a collection in the `collections/[collection]/test` directory with the extension `.yml`, and you can put more than one test in a single file.

At the moment the per-collection tests are pretty rudimentary, but you can test things like the following:

```yaml
- filename: nei.person.xml
  type: tei
  count: 16
  matches:
    - identifier: nei.person_braithwaite.w
      title_sort: Braithwaite, William Stanley, 1878-1962
    - identifier: nei.person_cawein.m
      title_sort: Cawein, Madison Julius, 1865-1914
```

The `filename` and `type` identify the location of the file you wish to test.  `count` should equal the number of docs you expect the file to return. For example, a single Cather letter file may return one doc, but the Neihardt personography file above will return 16 (one for each person and one for the personography file itself).

In the `matches` portion, you can match the id of the document(s) along with any other attributes you would like to test.  For example, cdrh:category, dc:title, and any other number of fields used in the Elasticsearch CDRH API schema. (TODO link)

This will run all of the new tests.

### Legacy Tests

** Leaving this here only until tests are completely moved to minitest instead of rspec **

Older tests are located in `test_old/ruby/lib_tests` currently.  Test fixtures are located at `test_old/ruby/fixtures` and include things like tei, files that can be "touched" to update their timestamp, and a tmp directory that will be filled and wiped by specific tests.  There are currently only tests for the helper functions, etc, so you would run tests as follows:

All tests:
```
rspec test_old/ruby/lib_tests/*
```
Specific group of tests (with documentation flag for a different progress reporter)
```
rspec test_old/ruby/lib_tests/transformer_test.rb --format documentation
```
At the end of the test run, you should see something like this:
```
Finished in 6.17 seconds (files took 0.57802 seconds to load)
47 examples, 0 failures, 9 pending
```
The pending ones are expected, as they just haven't been finished but those tests should be written in the future.  Failures are what you want to watch out for!
