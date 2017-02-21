# == openshift::util::yum_versionlock
#
# Lock Packages to specific versions
#
define openshift::util::yum_versionlock (
  $ensure = unset,
) {
  ensure_packages('yum-plugin-versionlock')

  $lock = "${title}-${ensure}"

  exec { "yum_versionlock ${title}":
    provider  => 'shell',
    command   => "yum -C versionlock delete '${title}'; yum -C versionlock '${lock}'",
    unless    => "yum -C versionlock list -q | grep -q '${lock}'",
    logoutput => on_failure,
    path      => $::path,
    require   => Package['yum-plugin-versionlock'],
  }
}
