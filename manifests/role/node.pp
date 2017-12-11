class openshift::role::node (
) {
  include ::openshift::util::cacert

  # Install pre-req packages
  # See https://docs.openshift.org/latest/install_config/install/host_preparation.html#installing-base-packages
  ensure_packages([
    'NetworkManager',
    'bash-completion',
    'bind-utils',
    'bridge-utils',
    'git',
    'lvm2',
    'net-tools',
    'wget',
  ])

  if downcase($::operatingsystem) == 'centos' {
    # The OpenShift Ansible playbooks require NetworkManager to be enabled and
    # started. Unlike on RedHat, CentOS does not install NetworkManager by default.
    # The playbooks don't handle this situation as of version 3.3.57-1.
    #
    # https://github.com/openshift/openshift-ansible/issues/1807
    #
    Package['NetworkManager'] ->
    service { 'openshift-networkmanager':
      name   => 'NetworkManager',
      ensure => 'running',
      enable => true,
    }
  }
}
