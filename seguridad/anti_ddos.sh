#!/bin/bash

echo "[🔥] Limpiando reglas conflictivas..."

# Eliminar cualquier regla ACCEPT que esté primera
FIRST_RULE=$(iptables -L INPUT --line-numbers | awk 'NR==3 {print $2}')
if [ "$FIRST_RULE" = "ACCEPT" ]; then
    echo "[⚠️] Regla ACCEPT al inicio detectada → eliminando..."
    iptables -D INPUT 1
fi

echo "[🔥] Estableciendo políticas de seguridad..."

# Policies seguras (indispensable para Anti-DDoS)
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

echo "[🔥] Limpiando reglas para aplicar mitigación..."
# Borra reglas antiguas de mitigación si existen
iptables -F INPUT

echo "[🛡️] Cargando reglas Anti-DDoS..."

# Limitar SYN Flood
iptables -A INPUT -p tcp --syn -m limit --limit 5/s --limit-burst 15 -j ACCEPT

# Limitar conexiones simultáneas por IP
iptables -A INPUT -p tcp -m connlimit --connlimit-above 30 -j DROP

# Limitar ICMP (ping)
iptables -A INPUT -p icmp -m limit --limit 1/s --limit-burst 5 -j ACCEPT

# Bloquear IPs sospechosas durante 60s
iptables -A INPUT -m recent --name BAD --rcheck --seconds 60 -j DROP

# Registrar IPs sospechosas
iptables -A INPUT -m recent --name BAD --set -j LOG --log-prefix "DDoS DETECTED: "

# Bloquear IPs marcadas
iptables -A INPUT -m recent --name BAD --set -j DROP

echo "[🔒] Agregando DROP final para cerrar la cadena..."
iptables -A INPUT -j DROP

echo "[💾] Guardando firewall..."
iptables-save > /etc/iptables/rules.v4

echo "[✅] Mitigación Anti-DDoS aplicada correctamente."
echo "[ℹ️] Validá con: sudo iptables -L -v --line-numbers"