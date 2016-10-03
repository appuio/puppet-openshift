# TODOs

* Firewall stuff!
* Deploy Ansible user and SSH key (see profile_openshift3::ansible)
* Default ansible_hosts_vars and merge with the one from Hiera
* ansible_hosts_vars probably in init.pp for further processing
* masters should also be in nodes children
* Manage /etc/sysconfig/docker-storage-setup
* Manage partitioning (LVM volume preparation)
* Integrate Gluster Playbook ?
* Registry IP
* Masters as Nodes -> merge hashes
* $run_ansible parameter
* Yum Versionlock support
* Support for OCP
* Integration into profile_openshift3
* Documentation
** vagrant.dev is not allowed in resolv.conf search when landrush returns wildcard
   answers. see
* openshift_hosted_router_selector='region=infra'
* openshift_hosted_router_replicas=2
* openshift_hosted_registry_selector='region=infra'
* openshift_hosted_registry_replicas=2
* https://github.com/openshift/openshift-ansible/blob/master/inventory/byo/hosts.origin.example

# Example Hieradata

```
---
classes:
  - openshift::role::ansible_master
  - profile_openshift3::ansible

openshift::role::ansible_master::run_ansible: false
openshift::role::ansible_master::masters_as_nodes: true
openshift::role::ansible_master::playbooks_version: 'openshift-ansible-3.3.28-1'
openshift::role::ansible_master::ansible_hosts_vars:
  ansible_become: true
  ansible_ssh_user: ansible
  containerized: true
  deployment_type: origin
  docker_version: 1.10.3
  openshift_hosted_manage_registry: true
  openshift_install_examples: true
  openshift_master_default_subdomain: apps.test.example.com
  openshift_master_identity_providers: [{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]
  openshift_release: v1.3.0
  openshift_use_manageiq: false
  openshift_use_nuage: false
  os_sdn_network_plugin_name: redhat/openshift-ovs-multitenant
openshift::role::ansible_master::ansible_hosts_children:
  masters:
    - name: origin-master1.vagrant.dev
      ip: 192.168.216.201
      node_labels:
        region: infra
      schedulable: true
  nodes:
    - name: origin-node1.vagrant.dev
      ip: 192.168.216.210
      node_labels:
        region: vagrant

profile_openshift3::ansible::ssh_public_key: ''
profile_openshift3::ansible::ssh_private_key: |
```

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with openshift](#setup)
    * [What openshift affects](#what-openshift-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with openshift](#beginning-with-openshift)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

A one-maybe-two sentence summary of what the module does/what problem it solves. This is your 30 second elevator pitch for your module. Consider including OS/Puppet version it works with.       

## Module Description

If applicable, this section should have a brief description of the technology the module integrates with and what that integration enables. This section should answer the questions: "What does this module *do*?" and "Why would I use it?"

If your module has a range of functionality (installation, configuration, management, etc.) this is the time to mention it.

## Setup

### What openshift affects

* A list of files, packages, services, or operations that the module will alter, impact, or execute on the system it's installed on.
* This is a great place to stick any warnings.
* Can be in list or paragraph form. 

### Setup Requirements **OPTIONAL**

If your module requires anything extra before setting up (pluginsync enabled, etc.), mention it here. 

### Beginning with openshift

The very basic steps needed for a user to get the module up and running. 

If your most recent release breaks compatibility or requires particular steps for upgrading, you may wish to include an additional section here: Upgrading (For an example, see http://forge.puppetlabs.com/puppetlabs/firewall).

## Usage

Put the classes, types, and resources for customizing, configuring, and doing the fancy stuff with your module here. 

## Reference

Here, list the classes, types, providers, facts, etc contained in your module. This section should include all of the under-the-hood workings of your module so people know what the module is touching on their system but don't need to mess with things. (We are working on automating this section!)

## Limitations

This is where you list OS compatibility, version compatibility, etc.

## Development

Since your module is awesome, other users will want to play with it. Let them know what the ground rules for contributing are.

## Release Notes/Contributors/Etc **Optional**

If you aren't using changelog, put your release notes here (though you should consider using changelog). You may also add any additional sections you feel are necessary or important to include here. Please use the `## ` header. 
