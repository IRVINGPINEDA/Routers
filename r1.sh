#!/bin/bash
echo "=== CONFIGURANDO R0 ==="

# 1. Configurar IPs estáticas
cat > /etc/netplan/01-netcfg.yaml << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      addresses: [192.168.0.1/24]    # Red para PC01 y PC02
    enp0s8:
      addresses: [192.168.0.1/30]    # Hacia R1
EOF
netplan apply

# 2. Habilitar IP forwarding
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p

# 3. Configurar FRR
cat > /etc/frr/frr.conf << EOF
hostname R0
!
interface enp0s3
 ip address 192.168.0.1/24
!
interface enp0s8
 ip address 192.168.0.1/30
!
ip route 0.0.0.0/0 192.168.0.2
!
line vty
!
EOF

# 4. Reiniciar FRR
systemctl restart frr
echo "R0 configurado correctamente"
