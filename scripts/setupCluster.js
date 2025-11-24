var dbPass = "root"
var clusterName = "devCluster"

try {
  print('Setting up InnoDB cluster...\n');
  shell.connect('root@mysql-server-1:3306', dbPass)

  var cluster = dba.createCluster(clusterName);

  print('Adding instances to the cluster.');
  cluster.addInstance({user: "root", host: "mysql-server-2", password: dbPass})
  print('.');
  cluster.addInstance({user: "root", host: "mysql-server-3", password: dbPass})

  print('.\nInstances successfully added to the cluster.');
  
} catch(e) {
  print('\nThe InnoDB cluster could not be created.\n\nError: ' + e.message + '\n');
}

// print("Configurando rejoin automático...\n");
// cluster.setOption("autoRejoinTries", 100);

// print("InnoDB Cluster listo con auto-rejoin ✅\n");