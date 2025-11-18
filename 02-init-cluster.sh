#!/bin/bash

echo "⚙️ Iniciando la configuración del cluster MySQL InnoDB Cluster..."

mysqlsh clusteradmin:cladmin@mysql-server-1:3306 --ssl-mode=DISABLED --js <<'EOF'
dba.configureInstance("clusteradmin@mysql-server-1:3306", {password: "cladmin", interactive:false, restart:true});
dba.configureInstance("clusteradmin@mysql-server-2:3306", {password: "cladmin", interactive:false, restart:true});
dba.configureInstance("clusteradmin@mysql-server-3:3306", {password: "cladmin", interactive:false, restart:true});
EOF

echo "⌛ Esperando a que los nodos reinicien..."
sleep 15   # ← Ajusta esto según tu máquina

mysqlsh clusteradmin:cladmin@mysql-server-1:3306 --ssl-mode=DISABLED --js <<'EOF'
var cluster = dba.createCluster("plaxCluster", {memberSslMode: "DISABLED"});
cluster.addInstance("clusteradmin@mysql-server-2:3306", {password:"cladmin", recoveryMethod:"clone"});
cluster.addInstance("clusteradmin@mysql-server-3:3306", {password:"cladmin", recoveryMethod:"clone"});
EOF

sleep 15

mysqlsh clusteradmin:cladmin@mysql-server-1:3306 --ssl-mode=DISABLED --js <<'EOF'
dba.getCluster("plaxCluster").status();
EOF

echo "✅ InnoDB Cluster configurado exitosamente!!!"