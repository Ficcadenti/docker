#!/bin/bash

docker-compose down -v
rm -rf ./master/data/*
rm -rf ./slave/data/*
docker-compose build
docker-compose up -d

docker exec mysql_master sh -c'chwon mysql:mysql /etc/mysql/conf.d/mysql.conf.cnf'
docker exec mysql_master sh -c'chmod 0444 /etc/mysql/conf.d/mysql.conf.cnf'

docker exec mysql_slave sh -c'chwon mysql:mysql /etc/mysql/conf.d/mysql.conf.cnf'
docker exec mysql_slave sh -c'chmod 0444 /etc/mysql/conf.d/mysql.conf.cnf'


until docker exec mysql_master sh -c 'export MYSQL_PWD=111; mysql -u root -p111 -e ";"'
do
    echo "Waiting for mysql_master database connection..."
    sleep 4
done

priv_stmt='CREATE USER "mydb_slave_user"@"%" IDENTIFIED BY "mydb_slave_pwd"; GRANT REPLICATION SLAVE ON *.* TO "mydb_slave_user"@"%"; FLUSH PRIVILEGES;'
docker exec mysql_master sh -c "export MYSQL_PWD=111; mysql -u root -p111 -e '$priv_stmt'"

until docker-compose exec mysql_slave sh -c 'export MYSQL_PWD=111; mysql -u root -p111 -e ";"'
do
    echo "Waiting for mysql_slave database connection..."
    sleep 4
done

MS_STATUS=`docker exec mysql_master sh -c 'export MYSQL_PWD=111; mysql -u root -p111 -e "SHOW MASTER STATUS"'`
CURRENT_LOG=`echo $MS_STATUS | awk '{print $6}'`
CURRENT_POS=`echo $MS_STATUS | awk '{print $7}'`

start_slave_stmt="CHANGE MASTER TO MASTER_HOST='mysql_master',MASTER_USER='mydb_slave_user',MASTER_PASSWORD='mydb_slave_pwd',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_slave_cmd='export MYSQL_PWD=111; mysql -u root -p111 -e "'
start_slave_cmd+="$start_slave_stmt"
start_slave_cmd+='"'
docker exec mysql_slave sh -c "$start_slave_cmd"

docker exec mysql_slave sh -c "export MYSQL_PWD=111; mysql -u root -p111 -e 'SHOW SLAVE STATUS \G'"
