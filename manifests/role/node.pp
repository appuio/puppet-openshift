class openshift::role::node (
) {

  # Install pre-req packages
  ensure_packages([
    'lvm2',
  ])
}
