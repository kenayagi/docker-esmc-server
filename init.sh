#!/bin/bash

while ! nc -z $DB_HOSTNAME 3306 ; do sleep 3; done
[ -e /opt/eset/RemoteAdministrator/Server/ERAServer ] || /usr/local/bin/install.sh
