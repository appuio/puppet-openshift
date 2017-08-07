# Puppet module for managing OpenShift - the Ansible part

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with openshift](#setup)
    * [What openshift affects](#what-openshift-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with openshift](#beginning-with-openshift)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This Puppet module manages Ansible for setting up an OpenShift cluster with the official
[openshift-ansible](https://github.com/openshift/openshift-ansible) Playbooks.

## Setup

### What `openshift` affects

The module has two "roles":

* `openshift::role::ansible_master`:
  * Installs Ansible
  * Checks out `openshift-ansible` from git
  * Configures SSH for Ansible
  * Writes the inventory file in YAML format
* `openshift::role::node`:
  * Installs required packages
  * Enables NetworkManager
  * Add some missing CA certificates

### Setup Requirements

Required modules:

* [vcsrepo](https://forge.puppet.com/puppetlabs/vcsrepo)
* [inifile](https://forge.puppet.com/puppetlabs/inifile)

### Beginning with `openshift`

On the host you want to run Ansible, apply the `ansible_master` role and pass the inventory to it:

```puppet
class { 'openshift::role::ansible_master':
  host_groups => {
    'OSEv3' => {
      children => ["nodes", "masters"],
    },
    masters => {
      vars => {
        osm_default_node_selector => "foo=bar",
      },
      hosts => {
        "master1.example.com" => {},
        "master2.example.com" => {},
      },
      children => ["etcd"],
    },
    nodes => {
      hosts => {
        "node[1:9].example.com" => {
          custom_var => true,
        },
      },
    },
  }
}
```

This parameters can also be configured in Hiera.

An all nodes, apply the `node` role:

```puppet
class { 'openshift::role::node': }
```

## Usage

## Reference

### Classes

#### Public Classes

* `openshift::role::ansible_master`: Installs and configures Ansible.

[*host_groups*]
  Default: {}. Hash of Ansible inventory data.

[*playbooks_source*]
  Default: https://github.com/openshift/openshift-ansible.git.
  Git repository where the Ansible plabooks are stored.

[*playbooks_version*]
  Default: master
  Git reference to check out

* `openshift::role::node`: Prepares node for OpenShift.

No parameters available.

## Limitations

This Puppet module only runs on CentOS and RHEL.

## Development

1. Fork it (https://github.com/appuio/puppet-openshift/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
