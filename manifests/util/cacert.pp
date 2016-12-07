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

  # As of December 7, 2016 "registry.access.redhat.com" is signed by
  # certificate authorities not included with the base system
  create_resources('file', {
    "${_anchor_dir}/DigiCertSHA2ExtendedValidationServerCA.pem" => {
      source => "puppet:///modules/${module_name}/DigiCertSHA2ExtendedValidationServerCA.pem",
    },
    "${_anchor_dir}/DigiCertSHA2HighAssuranceServerCA.pem" => {
      source => "puppet:///modules/${module_name}/DigiCertSHA2HighAssuranceServerCA.pem",
    },
  }, {
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['ca-certificates'],
    notify  => Exec['openshift-update-ca-trust'],
  })

  Package['ca-certificates'] ->
  exec { 'openshift-update-ca-trust':
    refreshonly => true,
    command     => '/bin/update-ca-trust',
  }
}
