#!/bin/bash

# Faz a lista dos databases disponiveis para o usuario configurado
# Faz o restore dos databases, a partir de arquivos .gz disponibilizados em um diretorio especifico
# Apos o restore, gera um dump da base e a compara com o arquivo original

# Configuracoes
DBHOST=''
DBUS=''
DBPASS=''
DBDIR='bases'
DBDIR_NOVAS_BASES='bases/novas'
LOGDIR='logs'
DATALOG=`date +%Y-%m-%d_%T`
LOGFILE="$LOGDIR/log-$DATALOG.log"
LOGFILE_DIFF="$LOGDIR/log-$DATALOG.dif.log"

DUMP_PARAM='--skip-comments --skip-extended-insert --routines' 
DUMP_IGNORE_TAB="--ignore-table=$db.logpk --ignore-table=$db.logPk --ignore-table=$db.logapp --ignore-table=$db.logApp"


# Conexao com o bd, listando as bases que o usuario possui acesso 
DATABASES=`mysql -h $DBHOST -u$DBUS -p$DBPASS  -e "SHOW DATABASES ;" | grep -Ev '(Database|information_schema)'`

# Lista de bases ignoradas no processo
DB_EXCEPT=("database1 database2")

for db in $DATABASES; do
	#Aplica a acao de restore para as bases que nao estao na $db_except
	if [[ " ${DB_EXCEPT[*]} " != *" $db "* ]]; then

		echo "`date +%Y-%m-%d_%T` - Inicio do Restore da base $db" >> "$LOGFILE"

		# Restore direto do arquivo gz, correspondente a base
		gunzip  <  $DBDIR/"$db".sql.gz | mysql -h$DBHOST -u$DBUS -p$DBPASS $db 

		# Descompatacao do arquivo original, para que seja possivel compara-lo com a base restaurada
		gzip -cd  $DBDIR/"$db".sql.gz > $DBDIR/"$db".sql 

		echo "`date +%Y-%m-%d_%T` - Fim do Restore da base $db" >> "$LOGFILE"
		echo "`date +%Y-%m-%d_%T` - Inicio do Dump da base $db" >> "$LOGFILE"
		
		# Dump da base recem-restaurada
		mysqldump $DUMP_PARAM -h $DBHOST -u$DBUS -p$DBPASS $db > $DBDIR_NOVAS_BASES/$db.sql
		echo "`date +%Y-%m-%d_%T` - Termino do Dump da base $db" >> "$LOGFILE"
		echo "DIFERENCA $db"  >> "$LOGFILE_DIFF.$db"
		
		# Comparacao do arquivo dump original e o da base recem-restaurada
		diff $DBDIR/"$db".sql $DBDIR_NOVAS_BASES/$db.sql   >> "$LOGFILE_DIFF.$db"
		echo "----------------------------------------------- "  >> "$LOGFILE_DIFF.$db"
		
	fi
done

