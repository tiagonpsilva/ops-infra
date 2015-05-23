#!/bin/bash

#Conecta no banco de origem e lista todas as bases que o usuario possui permissao
# Para cada base, executa um dump na origem remota, e a descarrega na base de destino local

DBUS_ORIGEM=''
DBPASS_ORIGEM=''
DBHOST_ORIGEM=''
DBUS_DESTINO=''
DBPASS_DESTINO=''
DBDIR='bases'
LOGDIR='logs'
DUMP='/usr/bin/mysqldump'
DUMP_PARAM='--extended-insert --single-transaction --routines --opt'
DUMP_IGNORE_TABLES=''
DATALOG=`date +%Y-%m-%d_%T`
LOGFILE="$LOGDIR/log-$DATALOG.log"
databases=`mysql -h $DBHOST_ORIGEM -u$DBUS_ORIGEM -p$DBPASS_ORIGEM  -e "SHOW DATABASES ;" | grep -Ev '(Database|information_schema)'`

for db in $databases; do

	echo "`date +%Y-%m-%d_%T` - Download da base $db" >> "$LOGFILE"
	$DUMP $DUMP_PARAM DUMP_IGONRE_TABLES -h $DBHOST_ORIGEM -u $DBUS_ORIGEM -p$DBPASS_ORIGEM $db |gzip > $DBDIR/$db.sql.gz
	
	echo "`date +%Y-%m-%d_%T`- Restore da base $db" >> "$LOGFILE"
	gunzip -c $DBDIR/$db.sql.gz| mysql -u $DBUS_DESTINO -p$DBPASS_DESTINO $db
	echo "`date +%Y-%m-%d_%T` Fim do processo $db" >> "$LOGFILE"

done

