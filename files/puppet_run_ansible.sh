#!/bin/bash

set -e -o pipefail

log_dir=/var/log/openshift-ansible
run_dir=/run/openshift-ansible
ansible_files="/usr/share/openshift-ansible /etc/ansible/hosts /etc/ansible/ansible.cfg"

mkdir -p $log_dir $run_dir

if [ "$1" == "-c" ]; then
  check_mode=true
  shift
else
  check_mode=false
fi

if [ "$1" == "-u" ]; then
  check_updates=true
  shift
else
  check_updates=false
fi

args=("$@")
playbook=`basename "$1"`

write_state_file() {
  echo "${args[@]}" > $1
  echo >> $1
  for file in $ansible_files; do
    [ -e ${file} ] && ls -lR ${file} >>$1
  done
  if [ $check_updates == true ]; then
    yum --disableplugin=versionlock list updates 2>/dev/null >> $1
  fi
}

# Idempotency check, used by puppet
if [ $check_mode == true ]; then
  [ -e $run_dir/$playbook.last ] || exit 1

  write_state_file $run_dir/$playbook.cur
  diff -q $run_dir/$playbook.last $run_dir/$playbook.cur >/dev/null
  exit
fi

stdbuf -o L ansible-playbook "$@" | tee $log_dir/ansible-`basename $playbook`.log

write_state_file $run_dir/$playbook.last
