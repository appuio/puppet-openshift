#!/bin/sh

if which openshift >/dev/null 2>&1; then
cat <<EOF
openshift_version=$(openshift version 2>/dev/null | sed -ne 's/openshift \+v\?\([0-9.]\+\).*/\1/p')
kubernetes_version=$(openshift version 2>/dev/null | sed -ne 's/kubernetes \+v\?\([0-9.]\+\).*/\1/p')
etcd_version=$(openshift version 2>/dev/null | sed -ne 's/etcd \+v\?\([0-9.]\+\).*/\1/p')
EOF
else
cat <<EOF
openshift_version=''
kubernetes_version=''
etcd_version=''
EOF
fi

