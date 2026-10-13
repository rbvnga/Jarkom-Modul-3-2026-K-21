# ISI SETUP_TENGEN.SH

#!/bin/bash
# Install jika belum terpasang
if ! dpkg -s isc-dhcp-server >/dev/null 2>&1; then
  apt-get update >/dev/null 2>&1
  apt-get install -y isc-dhcp-server >/dev/null 2>&1
fi

# Interface DHCP
if ! grep -q '^INTERFACESv4="eth0"' /etc/default/isc-dhcp-server 2>/dev/null; then
  cat <<'EOF' > /etc/default/isc-dhcp-server
INTERFACESv4="eth0"
INTERFACESv6=""
EOF
fi

# dhcpd.conf
if ! grep -q 'subnet 10.74.2.0' /etc/dhcp/dhcpd.conf 2>/dev/null; then
  cat <<'EOF' > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
authoritative;

# Network 4 - subnet lokal tengen, TANPA pool dinamis
subnet 10.74.4.0 netmask 255.255.255.0 {
}

# Network 2 - Divisi A (lewat DHCP relay)
subnet 10.74.2.0 netmask 255.255.255.0 {
  range 10.74.2.10 10.74.2.100;
  option routers 10.74.2.1;
  option broadcast-address 10.74.2.255;
  option domain-name-servers 10.74.1.2, 10.74.1.3;
}

# Network 3 - Divisi B (lewat DHCP relay)
subnet 10.74.3.0 netmask 255.255.255.0 {
  range 10.74.3.10 10.74.3.100;
  option routers 10.74.3.1;
  option broadcast-address 10.74.3.255;
  option domain-name-servers 10.74.1.2, 10.74.1.3;
}
EOF
fi

# File lease
mkdir -p /var/lib/dhcp
[ -f /var/lib/dhcp/dhcpd.leases ] || touch /var/lib/dhcp/dhcpd.leases

# Validasi lalu jalankan service
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status


# DI DAFTARKAN
cat <<EOF > /root/.bashrc
echo "nameserver 192.168.122.1" >> /etc/resolv.conf

chmod +x /root/setup_tengen.sh
./setup_tengen.sh
EOF



# VALIDASI KONFIGURASI
dhcpd -t -cf /etc/dhcp/dhcpd.conf
ps aux | grep dhcpd
