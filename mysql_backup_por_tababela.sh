#!/bin/bash

#################### SCRIPT PARA BACKUP MYSQL ####################
# Paulo César Cavalcante Silva <pc3168@gmail.com>                #
# Creado NOV, 2020                                               #
# Atualizado FEV, 2021                                           #

# Definindo parametros do MySQL
echo "  -- Definindo parametros do MySQL ..."
DB_NAME='nomebancodedados'
DB_USER='usuario'
DB_PASS='senha'

# Definindo parametros do sistema
echo "  -- Definindo parametros do sistema ..."
DB_PARAM=' --add-drop-table --add-locks --extended-insert --single-transaction -quick'
# parametros usando no sql.
#DB_PARAM1='--routines --triggers --add-drop-table --add-locks --extended-insert --single-transaction -quick'
## parametros usado somente para gerar procedures e triggers
DB_PARAM_SOMENTE_ROTINAS='--routines --triggers --no-create-info --no-data --no-create-db --skip-opt'


DIAS=60
FILIAL=$DB_NAME
DATE=`date +%d%m%Y%H%M`
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
BACKUP_DIR=/home/natusfarma/backup
DIRETORIO_SQL=sql
NAME_STORED_TRIGGERS='0_stored-triggers.sql'
BACKUP_TAR=$FILIAL-mysql-$DATE.tar


echo "  -- VERIFICANDO ARQUVIOS PARA SEREM APAGADOS MENOR QUE $DIAS DIAS"
find $BACKUP_DIR -type f -mtime +$DIAS | xargs rm -Rf


DADOS_TABELA=$($MYSQL -u$DB_USER -p$DB_PASS -e "USE $DB_NAME; SHOW TABLES;")
for i in $DADOS_TABELA
do
	#Gerando arquivo sql
	echo "  -- Gerando backup da base de dados $DB_NAME em $BACKUP_DIR/$DIRETORIO_SQL/$i.sql ..."
	$MYSQLDUMP $DB_NAME $DB_PARAM -u $DB_USER -p$DB_PASS $i > $BACKUP_DIR/$DIRETORIO_SQL/"$i.sql"
done
echo "  -- Gerando backup das stored e triggers do banco $DB_NAME em $BACKUP_DIR/$DIRETORIO_SQL/$NAME_STORED_TRIGGERS ..."
$MYSQLDUMP $DB_NAME $DB_PARAM_SOMENTE_ROTINAS -u $DB_USER -p$DB_PASS > $BACKUP_DIR/$DIRETORIO_SQL/$NAME_STORED_TRIGGERS

echo "  -- Alterando o diretório para $BACKUP_DIR/$DIRETORIO_SQL "
cd $BACKUP_DIR/$DIRETORIO_SQL

# Compactando arquivo em tar
echo "  -- Compactando arquivo em tar $BACKUP_DIR/$BACKUP_TAR *.sql ..."
tar -cf $BACKUP_DIR/$BACKUP_TAR *.sql

# Compactando arquivo em bzip2
echo "  -- Compactando arquivo em bzip2 $BACKUP_DIR/$BACKUP_TAR ..."
bzip2 $BACKUP_DIR/$BACKUP_TAR

# Excluindo arquivos desnecessarios
echo "  -- Excluindo arquivos desnecessarios $BACKUP_DIR/$DIRETORIO_SQL/*.sql ..."
rm -rf $BACKUP_DIR/$DIRETORIO_SQL/*.sql
echo "----------------------------FIM--------------------------------------"
