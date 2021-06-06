puppet-nodejs
=============

[![Build Status](https://github.com/willdurand/puppet-nodejs/actions/workflows/ci.yml/badge.svg)](https://github.com/willdurand/puppet-nodejs/actions)
[![Puppet Forge](https://img.shields.io/puppetforge/v/willdurand/nodejs.svg)](https://forge.puppetlabs.com/willdurand/nodejs)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/willdurand/nodejs.svg)](https://forge.puppetlabs.com/willdurand/nodejs)
[![Coverage Status](https://coveralls.io/repos/github/willdurand/puppet-nodejs/badge.svg)](https://coveralls.io/github/willdurand/puppet-nodejs)

This module allows you to install [Node.js](https://nodejs.org/) and
[NPM](https://npmjs.org/). This module is published on the Puppet Forge as
[willdurand/nodejs](https://forge.puppetlabs.com/willdurand/nodejs).

### Announcements

* The latest release is [2.1](https://github.com/willdurand/puppet-nodejs/releases/tag/2.1.0).

* On `master` development is happening for `2.2`.

* Legacy [1.9](https://github.com/willdurand/puppet-nodejs/tree/1.9) is still maintained, but won't
  receive any new features.

* For further information, please look at the [Support](#support) chapter.

## Installation

The module depends on the following well-adopted and commonly used modules:

* [puppetlabs/stdlib](https://github.com/puppetlabs/puppetlabs-stdlib)

The easiest approach to install this module is by using [r10k](https://github.com/puppetlabs/r10k):

``` ruby
forge 'http://forge.puppetlabs.com'

mod 'willdurand/nodejs', '2.0.3'
mod 'puppetlabs/stdlib', '5.1.0'
```

## Usage

### Deploying a precompiled package

There are a few ways to use this puppet module. The easiest one is just using the class definition
and specify a value for the version to install.

```puppet
class { 'nodejs':
  version => latest,
}
```

This installs the latest precompiled version available on `nodejs.org/dist`. `node` and `npm` will
be available in your `$PATH` at `/usr/local/bin`.

There are several ways to specify a target version of `node`:

* `version => latest` installs the latest version available.
* `version => lts` installs the latest long-term support version.
* `version => '9.x'` installs the latest version from the `v9` series.
* `version => '9.7` installs the latest 9.7 patch release.
* `version => '9.9.0'` installs exactly this version.


### Compiling from source

In order to compile from source with `gcc`, the `make_install` option must be `true`.

```puppet
class { 'nodejs':
  version      => 'lts',
  make_install => true,
}
```

### Using a custom source

It's also possible to deploy NodeJS instances to Puppet nodes from your own server.
This can be helpful when e.g. distributing your own, patched version of NodeJS.

The source can be specified like this:

``` puppet
class { '::nodejs':
  source => 'https://example.org/your-custom-nodejs-binaries.tar.gz',
}
```

It's also possible to compile the custom instance from source which is helpful when e.g.
deploying a patched NodeJS:

``` puppet
class { '::nodejs':
  source       => 'https://example.org/node-11.0.0.tar.gz',
  make_install => true,
}
```

Please note that the source needs to be a compressed tarball, but it doesn't matter
which format is in use (`.xz`,`.gz` etc). However additional packages such as `xz-utils` for Debian
have to be installed manually if needed (e.g. when providing a custom source which is bundled
as `.tar.xz`).

### Setup with a given download timeout

Due to infrastructures with slower connections the download timeout of the nodejs binaries can be increased
or disabled:

``` puppet
class { '::nodejs':
  download_timeout => 0,
}
```

For further information please refer to the
[`timeout` docs in Puppet](https://puppet.com/docs/puppet/5.3/types/exec.html#exec-attributes).

### Setup multiple versions of Node.js

If you need more than one installed version of Node.js on your machine, you can 
configure them using the `instances` list.

```puppet
class { '::nodejs':
  version => lts,
  instances => {
    "node-lts" => {
      version => lts
    },
    "node-9" => {
      version => '9.x'
    }
  },
}
```

This will install the three specified versions (latest version, current LTS version and latest `9.x` of
NodeJS) in `/usr/local/node`.

Important is that the default `node` and `npm` executable's versions need to be specified as
hash in the `instances` list.

The structure of linked executables in `/usr/local/bin` will look like this:

```
/usr/local/bin/node           # latest (default, linked to LTS in this case)
/usr/local/bin/node-v9.x.x    # latest 9.x
/usr/local/bin/node-v8.x.x    # latest LTS (ATM)

/usr/local/bin/npm            # NPM shipped with v8.x.x
/usr/local/bin/npm-v9.x.x     # NPM shipped with NodeJS 9.x
/usr/local/bin/npm-v8.x.x     # NPM shipped with NodeJS LTS
```

It is also possible to remove a single version like this:

```puppet
class { '::nodejs':
  # ...
  instances_to_remove => ['9.x.x'],
}
```

**Please** keep in mind that `instances_to_remove` doesn't remove version specifier like `lts` or
`latest`.

### Setup using custom amount of cpu cores

By default, all available cpu (that are detected using the `::processorcount` fact)  cores
are being used to compile nodejs. Set `cpu_cores` to any number of cores you want to use.
This is mainly intended for the use with `make_install => true` for parallelisation purposes.

```puppet
class { 'nodejs':
  version      => 'lts',
  cpu_cores    => 2,
  make_install => true,
}
```

### Configuring `$NODE_PATH`

The environment variable `$NODE_PATH` can be configured using the `init` manifest:

```puppet
class { '::nodejs':
  version   => 'lts',
  node_path => '/your/custom/node/path',
}
```

It is not possible to adjust a `$NODE_PATH` through ``::nodejs::install``.

### Binary path

`node` and `npm` are linked to `/usr/local/bin` to be available in your system `$PATH`
by default. To link those binaries to a different directory such as `/bin`, the parameter `target_dir`
can be modified accordingly:

```puppet
class { 'nodejs':
  version    => 'lts',
  target_dir => '/bin',
}
```

### NPM Provider

NPM packages can be installed just like any else package using Puppet's `package`
type, but with a special provider, namely `npm`:

```puppet
package { 'express':
  provider => npm
}
```

Note: When deploying a new machine without `nodejs` already installed, your npm
package definition requires the nodejs class:

```puppet
class { 'nodejs':
  version => 'lts'
}

package { 'express':
  provider => 'npm',
  require  => Class['nodejs']
}
```

### NPM installer (deprecated)

Note: this API is deprecated and will be removed in `3.0`. It's recommended to either package your
applications properly using `npm` and install them as package using the `npm` provider or to directly
run `npm install` when deploying your application (e.g. with a custom Puppet module).

This module is focused on setting up an environment with `nodejs`, application deployment should be handled
in its own module. In the end this was just a wrapper on top of `npm` which runs an `exec` with
`npm install` and a configurable user and lacks proper `ensure => absent` support.

The `nodejs` installer can be used if a npm package should not be installed globally, but in a
certain directory.

There are two approaches how to use this feature:

#### Installing a single package into a directory

```puppet
::nodejs::npm { 'npm-webpack':
  ensure    => present, # absent would uninstall this package
  pkg_name  => 'webpack',
  version   => 'x.x',               # optional
  options   => '-x -y -z',          # CLI options passed to the "npm install" cmd, optional
  exec_user => 'vagrant',           # exec user, optional
  directory => '/target/directory', # target directory
  home_dir  => '/home/vagrant',     # home directory of the user which runs the installation (vagrant in this case)
}
```

This would install the package ``webpack`` into ``/target/directory`` with version ``x.x``.

#### Executing a ``package.json`` file

```puppet
::nodejs::npm { 'npm-install-dir':
  list      => true,       # flag to tell puppet to execute the package.json file
  directory => '/target',
  exec_user => 'vagrant',
  options   => '-x -y -z',
}
```

### Proxy

When your puppet agent is behind a web proxy, export the `http_proxy` environment variable:

```bash
export http_proxy=http://myHttpProxy:8888
```

### Skipping package setup

As discussed in [willdurand/composer#44](https://github.com/willdurand/puppet-composer/issues/44)
each module should get a `build_deps` parameter which can be used in edge cases in order to turn
the package setup of this module off:

``` puppet
class { '::nodejs':
  build_deps => false,
}
```

In this case you'll need to take care of the following packages:

- `tar`
- `wget`
- `make` (if `make_install` = `true`)
- `gcc` compiler (if `make_install` = `true`)

## Hacking

The easiest way to get started is using [`bundler`](https://bundler.io):

```
bundle install
bundle exec rake test
PUPPET_INSTALL_TYPE=agent BEAKER_setfile=spec/acceptance/nodesets/ubuntu-1804-x64.yml bundle exec rake acceptance
```

**Note:** to run the acceptance tests that are part of rake's `test` target,
[Docker](https://www.docker.com/) is required.

## Authors

* William Durand (<william.durand1@gmail.com>)
* Johannes Graf ([@grafjo](https://github.com/grafjo))
* Maximilian Bosch ([@Ma27](https://github.com/Ma27))

## Support

There are currently two main branches available, namely the `1.9` branch and `2.x`. The
support lifecycle is planned like this:

* There's currently no plan to completely drop `1.9`. If there's demand for simple bugfixes
  or security-related problems, patches will be accepted and released, however there won't be any
  active feature development.

* Each release of `2.x` is supported until the next after the next release is published. So e.g.
  `2.0` is supported until `2.2` is published. Each release has its own branch where bugfixes
  can be backported, on `master` the next minor or major release is developed.

* There's currently no plan for a next major release.

## License

puppet-nodejs is released under the [MIT License](https://opensource.org/licenses/MIT). See the bundled
LICENSE file for details.
