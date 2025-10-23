#!/bin/bash
echo "=== CONFIGURANDO R3 ==="

# 1. Configurar IPs estáticas
cat > /etc/netplan/01-netcfg.yaml << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      addresses: [10.0.1.1/24]       # Red para servidores web DOS
    enp0s8:
      addresses: [192.168.0.10/30]   # Desde R2
    enp0s9:
      addresses: [192.168.0.13/30]   # Hacia R4
EOF
sudo netplan apply

# 2. Habilitar IP forwarding
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 3. Configurar FRR
sudo cat > /etc/frr/frr.conf << EOF
hostname R3
!
interface enp0s3
 ip address 10.0.1.1/24
!
interface enp0s8
 ip address 192.168.0.10/30
!
interface enp0s9
 ip address 192.168.0.13/30
!
ip route 192.168.0.0/24 192.168.0.9
ip route 202.0.0.0/24 192.168.0.9
ip route 10.0.0.0/24 192.168.0.9
ip route 192.168.0.16/30 192.168.0.14
!
line vty
!
EOF

# 4. Reiniciar FRR
sudo systemctl restart frr
echo "R3 configurado correctamente"