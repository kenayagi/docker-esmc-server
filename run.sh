#!/bin/bash

while ! nc -z $DB_HOSTNAME 3306 ; do sleep 3; done
[ -e /etc/init.d/eraserver ] || /usr/local/bin/install.sh
[ -e /etc/init.d/eraserver ] && /etc/init.d/eraserver start