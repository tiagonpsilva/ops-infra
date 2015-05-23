#!/bin/bash

# Compara dois databases, a partir dos arquivos dumps gerados

DBUS_ORIGEM=''
DBPASS_ORIGEM=''
DBHOST_ORIGEM=''
DBDIR_ORIGEM='bases'
DBDIR_CRIADAS='bases/criadas'
LOGDIR='logs/diff'
DUMP='/usr/bin/mysqldump'
DUMP_PARAM='--extended-insert --single-transaction --routines --opt'

DATALOG=`date +%Y-%m-%d_%T`
LOGFILE="$LOGDIR/log-diff-$DATALOG.log"
databases=`mysql -h $DBHOST_ORIGEM -u$DBUS_ORIGEM -p$DBPASS_ORIGEM  -e "SHOW DATABASES ;" | grep -Ev '(Database|information_schema)'`

for db in $databases; do

	echo "`date +%Y-%m-%d_%T` - Diff da base $db" >> $LOGFILE.$db
	$DUMP $DUMP_PARAM -h $DBHOST_ORIGEM -u $DBUS_ORIGEM -p$DBPASS_ORIGEM $db  > $DBDIR_CRIADAS/$db.sql
	 diff $DBDIR_ORIGEM/$db.sql  $DBDIR_CRIADAS/$db.sql >> $LOGFILE.$db

done

