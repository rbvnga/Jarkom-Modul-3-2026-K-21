# CEK MAC ADDRESS ITADORI, FUSHIGURO, ZENIN, OKKOTSU
ip link show eth0

# Ubah bagian Network 2 di /etc/dhcp/dhcpd.conf (tengen)
class "pool1" {
  match if (substring(hardware, 1, 6) = 02:42:be:59:63:00
         or substring(hardware, 1, 6) = 02:42:58:39:03:00 );
}

class "pool2" {
  match if (substring(hardware, 1, 6) = 02:42:93:36:d2:00
         or substring(hardware, 1, 6) = 02:42:6b:dc:19:00);
}

subnet 10.74.2.0 netmask 255.255.255.0 {
  option routers 10.74.2.1;
  option broadcast-address 10.74.2.255;
  option domain-name-servers 10.74.1.2, 10.74.1.3;

  pool {
    range 10.74.2.10 10.74.2.35;
    allow members of "pool1";
  }

  pool {
    range 10.74.2.70 10.74.2.95;
    allow members of "pool2";
  }
}


# ISI SETUP_TENGEN.SH
#!/bin/bash
# TENGEN - DHCP Server (isc-dhcp-server) 10.74.4.10

# ISI MAC ADDRESS KLIEN (huruf kecil, hasil: ip link show eth0)
MAC_ITADORI="aa:bb:cc:dd:ee:01"
MAC_FUSHIGURO="aa:bb:cc:dd:ee:02"
MAC_ZENIN="aa:bb:cc:dd:ee:03"
MAC_OKKOTSU="aa:bb:cc:dd:ee:04"

# Pastikan eth0 punya IP statis tengen
if ! ip -4 addr show eth0 | grep -q '10.74.4.10/24'; then
  ip addr add 10.74.4.10/24 dev eth0 2>/dev/null
  ip link set eth0 up
  ip route replace default via 10.74.4.1
fi

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

# File lease
mkdir -p /var/lib/dhcp
[ -f /var/lib/dhcp/dhcpd.leases ] || touch /var/lib/dhcp/dhcpd.leases

# dhcpd.conf (ditulis ulang hanya jika belum memuat pool berbasis class)
if ! grep -q 'allow members of "pool1"' /etc/dhcp/dhcpd.conf 2>/dev/null; then
  service isc-dhcp-server stop >/dev/null 2>&1
  : > /var/lib/dhcp/dhcpd.leases   # kosongkan lease lama agar pengujian bersih
  cat <<EOF > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
authoritative;

# Class Network 2: Pool 1 (itadori, fushiguro) dan Pool 2 (zenin, okkotsu)
class "pool1" {
  match if (substring(hardware, 1, 6) = $MAC_ITADORI
         or substring(hardware, 1, 6) = $MAC_FUSHIGURO);
}

class "pool2" {
  match if (substring(hardware, 1, 6) = $MAC_ZENIN
         or substring(hardware, 1, 6) = $MAC_OKKOTSU);
}

# Network 4 - subnet lokal tengen, TANPA pool dinamis
subnet 10.74.4.0 netmask 255.255.255.0 {
}

# Network 2 - Divisi A (lewat DHCP relay)
# Rentang 10.74.2.36 - 10.74.2.69 tidak dialokasikan
subnet 10.74.2.0 netmask 255.255.255.0 {
  option routers 10.74.2.1;
  option broadcast-address 10.74.2.255;
  option domain-name-servers 10.74.1.2, 10.74.1.3;

  pool {
    range 10.74.2.10 10.74.2.35;
    allow members of "pool1";
  }

  pool {
    range 10.74.2.70 10.74.2.95;
    allow members of "pool2";
  }
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

# Validasi lalu jalankan service
dhcpd -t -cf /etc/dhcp/dhcpd.conf
rm -f /var/run/dhcpd.pid
service isc-dhcp-server restart
service isc-dhcp-server status
ps aux | grep '[d]hcpd'


# DIDAFTARKAN 
cat <<EOF > /root/.bashrc
echo "nameserver 192.168.122.1" >> /etc/resolv.conf

chmod +x /root/setup_tengen.sh
./setup_tengen.sh
EOF

# CEK BUKTI IP YANG DI PEROLEH DI POOL 1 DAN POOL 2
ip route
ip a