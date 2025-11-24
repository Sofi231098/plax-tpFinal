#!/bin/bash

# ==========================
# Configuración del backup
# ==========================
MYSQL_HOST="mysql-server-1"
MYSQL_PORT="3306"
MYSQL_USER="backup"
MYSQL_PASSWORD="backup123"
MYSQL_DB="plax_db"

BACKUP_DIR="/backups"
RETENTION_DAYS=7   # cuántos días conservar

# ==========================
# FUNCIÓN DE BACKUP
# ==========================
realizar_backup () {
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    FILE_NAME="${MYSQL_DB}_${TIMESTAMP}.sql"

    echo "[backup] Generando backup: ${FILE_NAME}..."

    mysqldump \
      -h "$MYSQL_HOST" -P "$MYSQL_PORT" \
      -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" \
      --databases "$MYSQL_DB" \
      --single-transaction --quick --routines --events \
      --no-tablespaces \
      --set-gtid-purged=OFF \
      > "${BACKUP_DIR}/${FILE_NAME}"

    if [ $? -eq 0 ]; then
        echo "[backup] Backup OK: ${BACKUP_DIR}/${FILE_NAME}"
    else
        echo "[backup] ERROR al generar el backup" >&2
    fi

    echo "[backup] Limpiando archivos con más de ${RETENTION_DAYS} días..."
    find "$BACKUP_DIR" -type f -name "${MYSQL_DB}_*.sql" -mtime +$RETENTION_DAYS -delete
}

# ==========================
# SI SE LLAMA CON "now", HACER BACKUP INMEDIATO Y SALIR
# ==========================
if [ "$1" == "now" ]; then
    echo "[backup] Ejecutando backup inmediato..."
    realizar_backup
    exit 0
fi

# ==========================
# MODO AUTOMÁTICO (CADA 24 HORAS)
# ==========================
echo "[backup] Iniciando servicio de backups automáticos..."
echo "[backup] Esperando a que MySQL en ${MYSQL_HOST}:${MYSQL_PORT} esté disponible..."

until mysqladmin ping -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
  echo "[backup] MySQL aún no responde, reintentando en 5s..."
  sleep 5
done

echo "[backup] MySQL responde OK, comenzando ciclo de backups."
# Espera inicial para que el backend cree tablas/datos
echo "[backup] Esperando 2 minutos antes del primer backup para permitir la carga inicial de datos..."
sleep 120


while true; do
    realizar_backup
    echo "[backup] Próximo backup en 24 horas..."
    sleep 86400
done