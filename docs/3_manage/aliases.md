## Managing Aliases for Indices

Aliases are convenient ways to refer to a previously named index.  You can change which index an alias is pointing to, but any applications (like an API instance) will follow the alias to the new index, without you having to modify any configuration files.

## Add (and Update) Aliases

Note: the below is hardcoded for localhost

```
ruby scripts/ruby/es_alias_add.rb -a alias_name -i index_name

```

The above will take that alias, remove any other indices which it might have been pointing to, and then point it at the specified index. **Note: this script does not support multiple indices per alias, and will wipe them out.**

This means that if you already had an index named `test1` with an alias `alias1`, but you ran the following:

```
ruby scripts/ruby/es_alias_add.rb -a alias1 -i test2
```

`alias1` would now be pointed at `test2` instead of `test1`

After the script is run, a list of all current aliases per index will be printed out.

## List Aliases

Note: the below is hardcoded for localhost

```
ruby scripts/ruby/es_alias_list.rb
```

## Remove Alias

Note: the below is hardcoded for localhost

```
./scripts/shell/es_delete_alias.sh alias_name
```
