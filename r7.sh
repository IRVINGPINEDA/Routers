#!/bin/bash
echo "=== CONFIGURANDO R6 ==="

# 1. Configurar IPs estáticas
cat > /etc/netplan/01-netcfg.yaml << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      addresses: [172.16.2.1/24]     # Red local
    enp0s8:
      addresses: [192.168.0.22/30]   # Desde R5
    enp0s9:
      addresses: [192.168.0.25/30]   # Hacia R7
EOF
netplan apply

# 2. Habilitar IP forwarding
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p

# 3. Configurar FRR
cat > /etc/frr/frr.conf << EOF
hostname R6
!
interface enp0s3
 ip address 172.16.2.1/24
!
interface enp0s8
 ip address 192.168.0.22/30
!
interface enp0s9
 ip address 192.168.0.25/30
!
ip route 0.0.0.0/0 192.168.0.21
ip route 192.168.0.28/30 192.168.0.26
!
line vty
!
EOF

# 4. Reiniciar FRR
systemctl restart frr
echo "R6 configurado correctamente"
