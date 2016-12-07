# == openshift::util::cacert
#
# Install additional CAs as trusted.
#
# === Parameters
#
# (none)
#
class openshift::util::cacert {
  ensure_packages(['ca-certificates'])

  $_anchor_dir = '/etc/pki/ca-trust/source/anchors'

  # As of December 7, 2016 "registry.access.redhat.com" uses a certificate not
  # included in the certificate authorities provided by the base system
  file { "${_anchor_dir}/DigiCertSHA2ExtendedValidationServerCA.pem":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => "puppet:///modules/${module_name}/DigiCertSHA2ExtendedValidationServerCA.pem",
    require => Package['ca-certificates'],
    notify  => Exec['openshift-update-ca-trust'],
  }

  Package['ca-certificates'] ->
  exec { 'openshift-update-ca-trust':
    refreshonly => true,
    command     => '/bin/update-ca-trust',
  }
}
