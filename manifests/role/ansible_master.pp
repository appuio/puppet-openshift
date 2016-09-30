class openshift::role::ansible_master (
  $playbooks_version = 'master',
  $playbooks_source = 'https://github.com/openshift/openshift-ansible.git',
  $ansible_hosts_vars = {},
  $ansible_hosts_children = {},
) {

  # Install pre-req packages for the ansible master
  # This needs epel enabled and we probably need
  # to version-lock ansible TODO
  ensure_packages([
    'ansible',
    'git',
    'jq',
    'pyOpenSSL',
    'wget',
  ])

  # Get OpenShift Ansible playbooks
  vcsrepo { '/usr/share/openshift-ansible':
    ensure   => present,
    provider => git,
    revision => $playbooks_version,
    source   => $playbooks_source,
  } ->

  # Set some Ansible configuration values
  augeas { 'ansible.cfg':
    lens    => 'Puppet.lns',
    incl    => '/etc/ansible/ansible.cfg',
    changes => [
      'set /files/etc/ansible/ansible.cfg/ssh_connection/pipelining True',
      'set /files/etc/ansible/ansible.cfg/ssh_connection/control_path /tmp/ansible-ssh-%%h-%%p-%%r',
    ],
    require => Package['ansible'],
  } ->

  # Write Ansible hosts file (this is the main configuration!)
  file { '/etc/ansible/hosts':
    ensure  => file,
    content => template('openshift/ansible_hosts.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    require => Package['ansible'],
  } ->

  # Deploy the Ansible run script
  file { '/usr/local/bin/puppet_run_ansible.sh':
    ensure => file,
    source => 'puppet:///modules/openshift/puppet_run_ansible.sh',
    owner  => 'root',
    group  => 'root',
    mode   => '0770',
  } ->

  # Execute Ansible
  ::openshift::ansible::run { 'playbooks/byo/config.yml':
    cwd => '/usr/share/openshift-ansible',
  }

}
