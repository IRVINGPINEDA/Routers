#!/bin/bash
echo "=== CONFIGURANDO R1 ==="

# 1. Configurar IPs estáticas
cat > /etc/netplan/01-netcfg.yaml << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      addresses: [202.0.0.1/24]      # Red para servidores DNS
    enp0s8:
      addresses: [192.168.0.2/30]    # Desde R0
    enp0s9:
      addresses: [192.168.0.5/30]    # Hacia R2
EOF
sudo netplan apply

# 2. Habilitar IP forwarding
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 3. Configurar FRR
sudo cat > /etc/frr/frr.conf << EOF
hostname R1
!
interface enp0s3
 ip address 202.0.0.1/24
!
interface enp0s8
 ip address 192.168.0.2/30
!
interface enp0s9
 ip address 192.168.0.5/30
!
ip route 192.168.0.0/24 192.168.0.1
ip route 192.168.0.8/30 192.168.0.6
!
line vty
!
EOF

# 4. Reiniciar FRR
sudo systemctl restart frr
echo "R1 configurado correctamente"