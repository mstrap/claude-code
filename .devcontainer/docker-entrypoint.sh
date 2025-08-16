#!/bin/bash
set -e
/usr/local/bin/init-firewall.sh
exec su -c "$*" node
