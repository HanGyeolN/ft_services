#!/bin/sh
#sh -c 'tail -f /dev/null'

mysql_install_db --user=root --datadir=/var/lib/mysql
mysqld --user=root --bootstrap --verbose=0 < init.sql
mysqld
