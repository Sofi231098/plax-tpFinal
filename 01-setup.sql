CREATE USER 'clusteradmin'@'%' IDENTIFIED BY 'cladmin';
GRANT ALL privileges ON *.* TO 'clusteradmin'@'%' with grant option;
RESET MASTER;

CREATE DATABASE IF NOT EXISTS plax_db;
CREATE USER IF NOT EXISTS 'plax'@'%' IDENTIFIED BY 'plax';
GRANT ALL PRIVILEGES ON plax_db.* TO 'plax'@'%';
FLUSH PRIVILEGES;