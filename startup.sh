#!/bin/sh

set -e

cd /
nginx &

DATADIR="/var/lib/mysql"
tempSqlFile='/database.sql'
if [ ! -d "$DATADIR/mysql" ]; then
	
	echo 'Running mysql_install_db ...'
	mysql_install_db --datadir="$DATADIR"
	echo 'Finished mysql_install_db'
		
	mysqld_safe --user=root --init-file="$tempSqlFile" &
else
	mysqld_safe --user=root --init-file="$tempSqlFile" &
fi

### waiting database
while !(mysqladmin --user=root --password=secret-1234 ping)
do
   sleep 3
   echo "waiting for mysql ..."
done

cd /app/backend
if [ ! -d "/app.init.done" ]; then
	npm run schema-sync
	npm run init
	touch /app.init.done
fi

cd /app/backend
npm run start:prod