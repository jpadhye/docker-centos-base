#!/bin/bash

set -e

## requires running as root because filesystem package won't install otherwise,
## giving a cryptic error about /proc, cpio, and utime.  As a result, /tmp
## doesn't exist.
tmpdir=$( mktemp -d )
trap "echo removing ${tmpdir}; rm -rf ${tmpdir}" EXIT

febootstrap \
    -u http://mirrors.mit.edu/centos/6.5/updates/x86_64/ \
    -i centos-release \
    -i yum \
    -i iputils \
    -i tar \
    -i which \
    centos65 \
    ${tmpdir} \
    http://mirrors.mit.edu/centos/6.5/os/x86_64/

febootstrap-run ${tmpdir} -- sh -c 'echo "NETWORKING=yes" > /etc/sysconfig/network'
febootstrap-run ${tmpdir} -- yum clean all

## xz gives the smallest size by far, compared to bzip2 and gzip, by like 50%!
febootstrap-run ${tmpdir} -- tar -cf - . | xz > centos65.tar.xz
