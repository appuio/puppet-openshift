define openshift::ansible::run (
  $check_options = '',
  $cwd = undef,
  $options = '',
) {

  # This first exec is a workaround to have a better Puppet run output experience
  exec { "Running ansible-playbook ${name} ${options}":
    command => "echo Running Ansible playbook ${name}",
    unless  => "/usr/local/bin/puppet_run_ansible.sh -c ${check_options} ${name} ${options}",
    path    => $::path,
  } ->

  exec { "ansible-playbook ${name}":
    command   => "/usr/local/bin/puppet_run_ansible.sh ${check_options} ${name} ${options}",
    cwd       => $cwd,
    logoutput => 'on_failure',
    path      => $::path,
    timeout   => 1000,
    unless    => "/usr/local/bin/puppet_run_ansible.sh -c ${check_options} ${name} ${options}",
  }

}
