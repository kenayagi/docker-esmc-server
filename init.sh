#!/bin/bash

sleep 10s
[ -e /etc/init.d/eraserver ] || /usr/local/bin/install.sh
