# Etcd/Chef integration

[Etcd](https://github.com/coreos/etcd) is a distributed key/value store, designed
for service discovery and configuration alongside [OS containers](http://coreos.com/). For
services and tools that don't directly support etcd, etcd-chef provides a way
to write out configuration files and reload processes using the standard
[Chef](http://docs.opscode.com/) DSL.

## Running etcd-chef

`etcd-chef` takes most of the same options as `chef-solo` with a few exceptions.
`--interval` will only have
an effect on failed runs, as normal runs wait on etcd changes (see below for more
information). Beyond that, use `etcd-chef` just as you would `chef-solo`:

```bash
$ etcd-chef -c config.rb
```

## Accessing etcd values

Within your Chef recipes, you can use `etcd` in a similar way as you would
normally use `node` to access attributes:

```ruby
template '/etc/...' do
  variables secret_key: etcd['myapp']['secret_key']
end
```

## Synchronized with etcd

`etcd-chef` automatically waits for a change in etcd and runs a converge cycle.
This means that as soon as the cluster propagates a change, all `etcd-chef`
daemons will activate. You may wish to set a `--splay` time if your recipe
code involves non-local or contended resources.

## Configuration

By default an `etcd` instance on localhost will be used. You can customize this
either via `--etcd-host` and `--etcd-port` command line options, or `etcd_host`
and `etcd_port` in your configuration file.
