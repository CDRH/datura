## Managing Aliases for Indices

Aliases are convenient ways to refer to a previously named index.  You can change which index an alias is pointing to, but any applications (like an API instance) will follow the alias to the new index, without you having to modify any configuration files.

## Add (and Update) Aliases

Note: the below is hardcoded for localhost

```
es_alias_add -a alias_name -i index_name

```

The above will take that alias, remove any other indices which it might have been pointing to, and then point it at the specified index.

This means that if you already had an index named `test1` with an alias `alias1`, but you ran the following:

```
es_alias_add -a alias1 -i test2
```

`alias1` would now be pointed at `test2` instead of `test1`

After the script is run, a list of all current aliases per index will be printed out.

## List Aliases

TODO the following need to be updated to use environments

```
es_alias_list
```

## Remove Alias

```
es_delete_alias
```
