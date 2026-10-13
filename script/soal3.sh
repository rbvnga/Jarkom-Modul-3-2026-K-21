# ISI SETUP_JINCHI.SH

#!/bin/bash
# JICHI - Router Utama, NAT, dan DHCP Relay

# Install isc-dhcp-relay jika belum terpasang
if ! dpkg -s isc-dhcp-relay >/dev/null 2>&1; then
  apt-get update >/dev/null 2>&1
  DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-relay >/dev/null 2>&1
fi

# Konfigurasi relay: teruskan ke tengen lewat eth2, eth3 (klien) dan eth4 (jalur ke tengen)
if ! grep -q '^SERVERS="10.74.4.10"' /etc/default/isc-dhcp-relay 2>/dev/null; then
  cat <<'EOF' > /etc/default/isc-dhcp-relay
SERVERS="10.74.4.10"
INTERFACES="eth2 eth3 eth4"
OPTIONS=""
EOF
fi

# Jalankan ulang relay dan tampilkan bukti
service isc-dhcp-relay restart
service isc-dhcp-relay status
ps aux | grep '[d]hcrelay'


# DI DAFTARKAN
cat <<EOF > /root/.bashrc
echo "nameserver 192.168.122.1" >> /etc/resolv.conf

chmod +x /root/setup_jichi.sh
./setup_jichi.sh
EOF

# PEMBUKTIAN DI CLIENT ALPINET
udhcpc -i eth0
ip a
ip route


# PENAMBAHAN KONFIGURASI DI SETIAP CLIENT ALPINET
   auto eth0
   iface eth0 inet dhcp
