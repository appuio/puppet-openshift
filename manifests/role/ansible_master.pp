# == openshift::role::ansible_master
#
# === Parameters
#
# [*host_groups*]
#   Hash describing Ansible host groups. Each entry has the group name as its
#   key and the optional keys "children" (array with child groups), "vars"
#   (group-wide variables) or "hosts" (hash with machine names and hash as
#   a value; the latter hash contains per-machine variables). Node names can be
#   the full syntax supported by Ansible (i.e. "node[1:4].example.com").
#
#   Example: {
#     OSEv3 => {
#       children => ["nodes", "masters"],
#     },
#     masters => {
#       vars => {
#         osm_default_node_selector => "foo=bar",
#       },
#       hosts => {
#         "master1.example.com" => {},
#         "master2.example.com" => {},
#       },
#       children => ["etcd"],
#     },
#     nodes => {
#       hosts => {
#         "node[1:9].example.com" => {
#           custom_var => true,
#         },
#       },
#     },
#   }
#
class openshift::role::ansible_master (
  $host_groups,
  $playbooks_source = 'https://github.com/openshift/openshift-ansible.git',
  $playbooks_version = 'master',
) {
  validate_hash($host_groups)

  include ::openshift::util::cacert

  ensure_packages([
    'yum-plugin-versionlock',
    ])

  # Use puppet/yum module with yum::versionlock instead of attempting a custom
  # implementation
  Package[yum-plugin-versionlock] ->
  exec { 'delete-ansible-versionlock':
    provider => 'shell',
    onlyif => sprintf('/usr/bin/yum --cacheonly versionlock list | grep %s',
      shellquote('^0:ansible-2\.2\.')),
    command => '/usr/bin/yum --cacheonly versionlock delete "ansible-2.2.*"',
  } ->
  Package[ansible]

  # Install pre-req packages for the ansible master
  # This needs epel enabled
  ensure_packages([
    'ansible',
    'git',
    'jq',
    'pyOpenSSL',
    'wget',
  ])

  # Get OpenShift Ansible playbooks
  vcsrepo { 'openshift-ansible':
    ensure   => present,
    path     => '/usr/share/openshift-ansible',
    provider => git,
    revision => $playbooks_version,
    source   => $playbooks_source,
  }

  create_resources('ini_setting', prefix({
    'ssh-conn-pipelining' => {
      section => 'ssh_connection',
      setting => 'pipelining',
      value   => 'True',
    },
    'ssh-conn-controlpath' => {
      section => 'ssh_connection',
      setting => 'control_path',
      value   => '/tmp/ansible-ssh-%%h-%%p-%%r',
    },
    }, 'ansible-cfg-'), {
      ensure  => present,
      path    => '/etc/ansible/ansible.cfg',
      require => Package[ansible],
    })

  # Main Ansible configuration
  file { '/etc/ansible/hosts':
    ensure       => file,
    content      => template('openshift/ansible_hosts.erb'),
    owner        => 'root',
    group        => 'root',
    mode         => '0640',
    require      => Package['ansible'],

    # https://docs.ansible.com/ansible/meta_module.html
    validate_cmd => '/bin/ansible -i % -m meta -a noop localhost',
  }

  # Remove script no longer in use
  file { '/usr/local/bin/puppet_run_ansible.sh':
    ensure => absent,
  }
}
