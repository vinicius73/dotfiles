# Useful Commands and Scripts

## Delete project cache and dependencies

### Delete all `node_modules`

> From https://stackoverflow.com/questions/42950501/delete-node-modules-folder-recursively-from-a-specified-path-using-command-line

```sh
# list all
find . -name 'node_modules' -type d -prune

# remove all
find . -name 'node_modules' -type d -prune -exec rm -rf '{}' +
```

### Find `vendor` folders

```sh
find . -name 'vendor' -type d -prune
```

### Find yarn cache

```sh
find . -regextype sed -regex ".*/.yarn/cache"
find . -regextype sed -regex ".*/.yarn/cache" -exec rm -rf '{}' +

find . -regextype sed -regex ".*/.yarn/install-state.gz" -exec rm -rf '{}' +
```

### Find caches and tmp

```sh
find . -regextype sed -regex ".*/.terraform" -exec du -hs '{}' +
find . -regextype sed -regex ".*/.tmp" -exec du -hs '{}' +
find . -regextype sed -regex ".*/coverage" -exec du -hs '{}' +
```

### Go bin and pkg

```sh
cd $GOPATH
pwd
rm -rf ./*
```