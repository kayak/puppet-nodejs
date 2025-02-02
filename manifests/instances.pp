# = Class: nodejs::instances
#
# == Parameters:
#
# [*instances*]
#   The list of nodejs instances to be installed.
#
# [*node_version*]
#   The evaluated node version which is either the only one or the default instance.
#
# [*target_dir*]
#   The target dir where to install the executables.
#
# [*make_install*]
#   Whether or not to compile from source.
#
# [*cpu_cores*]
#   How many CPU cores to use for the compile from source (only used when $make_install = true)
#
# [*instances_to_remove*]
#   The list of instances to remove.
#
# [*nodejs_default_path*]
#   The path of the default installation.
#
# [*download_timeout*]
#   Maximum time for the download of the nodejs sources.
#
# [*install_dir*]
#   Where to deploy the NodeJS instances into.
#
# [*source*]
#  Where to fetch the NodeJS instances (either sources or binary distributions).
#
class nodejs::instances(
  Hash[String, Hash] $instances,
  String $node_version,
  String $target_dir,
  Boolean $make_install,
  Integer $cpu_cores,
  Array[String] $instances_to_remove,
  String $nodejs_default_path,
  Integer $download_timeout,
  String $install_dir,
  Optional[String] $source = undef,
  Optional[String] $urlbase = undef,
) {
  if $caller_module_name != $module_name {
    warning('nodejs::instances is private!')
  }

  if count($instances) == 0 {
    nodejs::instance { "nodejs-custom-instance-${node_version}":
      ensure               => present,
      version              => $node_version,
      target_dir           => $target_dir,
      make_install         => $make_install,
      cpu_cores            => $cpu_cores,
      default_node_version => undef,
      timeout              => $download_timeout,
      install_dir          => $install_dir,
      source               => $source,
      urlbase              => $urlbase,
    }
  } else {
    create_resources('::nodejs::instance', ::nodejs::node_instances($instances, true), {
      ensure               => present,
      target_dir           => $target_dir,
      make_install         => $make_install,
      cpu_cores            => $cpu_cores,
      default_node_version => undef,
      timeout              => $download_timeout,
      install_dir          => $install_dir,
      urlbase              => $urlbase,
    })

    if !defined(Nodejs::Instance["nodejs-custom-instance-${$node_version}"]) {
      fail("Cannot create a default instance with version `${$node_version}` if this version is not defined in the `instances` list!")
    }
  }

  if count($instances_to_remove) > 0 {
    create_resources('::nodejs::instance', ::nodejs::node_instances($instances_to_remove, false), {
      ensure               => absent,
      make_install         => false,
      cpu_cores            => 0,
      target_dir           => $target_dir,
      default_node_version => $node_version,
      timeout              => $download_timeout,
      install_dir          => $install_dir,
    })
  }

  if $source == undef {
    $nodejs_version_path = "${install_dir}/node-${node_version}"
  } else {
    $filename            = ::nodejs::source_filename($source)
    $nodejs_version_path = "${install_dir}/node-${filename}"
  }

  file { $nodejs_default_path:
    ensure  => link,
    target  => $nodejs_version_path,
    require => Nodejs::Instance["nodejs-custom-instance-${$node_version}"],
  }

  $node_default_symlink        = "${target_dir}/node"
  $node_default_symlink_target = "${nodejs_default_path}/bin/node"
  $npm_default_symlink         = "${target_dir}/npm"
  $npm_default_symlink_target  = "${nodejs_default_path}/bin/npm"

  file { $node_default_symlink:
    ensure  => link,
    target  => $node_default_symlink_target,
    require => File[$nodejs_default_path]
  }

  file { $npm_default_symlink:
    ensure  => link,
    target  => $npm_default_symlink_target,
    require => File[$nodejs_default_path]
  }
}
