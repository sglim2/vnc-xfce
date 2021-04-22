#!/usr/bin/env bash

set -e

echo "nss-wrapper - needed to execute image as non-root"
dnf -y install nss_wrapper gettext
dnf clean all
rm -rf /var/cache/dnf

echo 'source $STARTUPDIR/container-user' >> $HOME/.bashrc
