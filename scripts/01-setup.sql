CREATE USER 'clusteradmin'@'%' IDENTIFIED BY 'cladmin';
GRANT ALL privileges ON *.* TO 'clusteradmin'@'%' with grant option;
RESET MASTER;

CREATE USER 'exporter'@'%' IDENTIFIED WITH mysql_native_password BY 'exporter_pass'; 
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';

CREATE DATABASE IF NOT EXISTS plax_db;
CREATE USER IF NOT EXISTS 'plax'@'%' IDENTIFIED BY 'plax';
GRANT ALL PRIVILEGES ON plax_db.* TO 'plax'@'%';
FLUSH PRIVILEGES;