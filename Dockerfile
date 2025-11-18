FROM mysql/mysql-server:8.0

COPY ./01-setup.sql /docker-entrypoint-initdb.d

EXPOSE 3306