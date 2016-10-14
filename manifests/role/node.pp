class openshift::role::node (
) {

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

}
