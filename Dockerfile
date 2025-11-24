FROM mysql/mysql-server:8.0

COPY ./scripts/01-setup.sql         /docker-entrypoint-initdb.d/01-setup.sql
COPY ./scripts/02-backup-user.sql   /docker-entrypoint-initdb.d/02-backup-user.sql

EXPOSE 3306
