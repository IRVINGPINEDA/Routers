#!/bin/bash
echo "=== CONFIGURANDO R0 ==="

# 1. Verificar e instalar netplan si es necesario
if ! command -v netplan &> /dev/null; then
    echo "Instalando netplan..."
    apt update && apt install -y netplan.io
fi

# 2. Crear directorio si no existe
mkdir -p /etc/netplan

# 3. Configurar IPs estáticas con permisos correctos
cat > /tmp/01-netcfg.yaml << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      addresses: [192.168.0.1/24]
    enp0s8:
      addresses: [192.168.0.1/30]
EOF

# 4. Mover con permisos correctos (600)
mv /tmp/01-netcfg.yaml /etc/netplan/01-netcfg.yaml
chmod 600 /etc/netplan/01-netcfg.yaml
chown root:root /etc/netplan/01-netcfg.yaml

# 5. Asegurar que systemd-networkd esté corriendo
systemctl enable systemd-networkd
systemctl start systemd-networkd

# 6. Aplicar configuración de red
netplan apply
sleep 3

# 7. Habilitar IP forwarding
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p

# 8. Verificar que FRR está instalado
if ! systemctl is-active --quiet frr; then
    echo "FRR no está instalado. Ejecuta primero ./install_frr.sh"
    exit 1
fi

# 9. Configurar FRR
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

# 10. Reiniciar FRR
systemctl restart frr
echo "R0 configurado correctamente"
