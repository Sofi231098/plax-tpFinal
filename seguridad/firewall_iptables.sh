#!/bin/sh
iptables -F
iptables -X
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
for p in 8080 5173 6446 3306 3000 9090 9104 8081; do
 iptables -A INPUT -p tcp --dport $p -j ACCEPT
done
iptables -A INPUT -p tcp --syn -m limit --limit 5/s --limit-burst 10 -j ACCEPT
iptables -A INPUT -j LOG --log-prefix "IPTABLES DROP: "
