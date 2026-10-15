# ISI SETUP_JICHI.SH
#!/bin/bash
# JICHI - Router utama, NAT, dan DHCP Relay (aman dijalankan berulang)

# 1. Interface (eth0 dari NAT1 lewat DHCP, eth1-eth4 statis)
cat <<'EOF' > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
  address 10.74.1.1
  netmask 255.255.255.0

auto eth2
iface eth2 inet static
  address 10.74.2.1
  netmask 255.255.255.0

auto eth3
iface eth3 inet static
  address 10.74.3.1
  netmask 255.255.255.0

auto eth4
iface eth4 inet static
  address 10.74.4.1
  netmask 255.255.255.0
EOF

# Pasang IP langsung bila belum ada (container tidak menjalankan init)
ip addr show eth1 | grep -q '10.74.1.1/' || ip addr add 10.74.1.1/24 dev eth1
ip addr show eth2 | grep -q '10.74.2.1/' || ip addr add 10.74.2.1/24 dev eth2
ip addr show eth3 | grep -q '10.74.3.1/' || ip addr add 10.74.3.1/24 dev eth3
ip addr show eth4 | grep -q '10.74.4.1/' || ip addr add 10.74.4.1/24 dev eth4
for i in eth1 eth2 eth3 eth4; do ip link set "$i" up; done
ip route show default | grep -q . || udhcpc -i eth0 -n -q >/dev/null 2>&1

# 2. Forwarding dan NAT
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || \
  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# 3. Install DHCP Relay jika belum terpasang
if ! dpkg -s isc-dhcp-relay >/dev/null 2>&1; then
  apt-get update >/dev/null 2>&1
  DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-relay >/dev/null 2>&1
fi

# 4. Konfigurasi relay: teruskan ke tengen lewat eth2, eth3 (klien) dan eth4 (jalur ke tengen)
cat <<'EOF' > /etc/default/isc-dhcp-relay
SERVERS="10.74.4.10"
INTERFACES="eth2 eth3 eth4"
OPTIONS=""
EOF

# 5. Daftarkan autostart DHCP Relay
#    (di container dumb-init tanpa init, pemulihan dijamin oleh .bashrc yang memanggil script ini)
if [ -d /run/systemd/system ]; then
  systemctl enable isc-dhcp-relay >/dev/null 2>&1
else
  update-rc.d isc-dhcp-relay defaults >/dev/null 2>&1
fi

# 6. Jalankan ulang relay dan tampilkan bukti
service isc-dhcp-relay restart
service isc-dhcp-relay status
ps aux | grep '[d]hcrelay'

# DIDAFTARKAN 
cat <<EOF > /root/.bashrc
echo "nameserver 192.168.122.1" >> /etc/resolv.conf

chmod +x /root/setup_jichi.sh
./setup_jichi.sh
EOF


# ISI SETUP_TENGEN.SH
#!/bin/bash
# TENGEN - DHCP Server (isc-dhcp-server) 10.74.4.10

KELOMPOK="K-21"

# MAC ADDRESS KLIEN NETWORK 2
MAC_ITADORI="02:42:be:59:63:00"
MAC_FUSHIGURO="02:42:58:39:03:00"
MAC_ZENIN="02:42:93:36:d2:00"
MAC_OKKOTSU="02:42:6b:dc:19:00"

# MAC ADDRESS KLIEN NETWORK 3
MAC_INO="02:42:b6:4e:2a:00"
MAC_KUSAKABE="02:42:da:db:58:00"
MAC_MIWA="02:42:58:d7:86:00"
MAC_KUGISAKI="02:42:7c:b4:fc:00"

# 1. Pastikan eth0 punya IP statis tengen dan rute default ke jichi
if ! ip -4 addr show eth0 | grep -q '10.74.4.10/24'; then
  ip addr add 10.74.4.10/24 dev eth0 2>/dev/null
fi
ip link set eth0 up
ip route replace default via 10.74.4.1

# 2. Install jika belum terpasang
if ! dpkg -s isc-dhcp-server >/dev/null 2>&1; then
  apt-get update >/dev/null 2>&1
  DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-server >/dev/null 2>&1
fi

# 3. Interface DHCP
if ! grep -q '^INTERFACESv4="eth0"' /etc/default/isc-dhcp-server 2>/dev/null; then
  cat <<'EOF' > /etc/default/isc-dhcp-server
INTERFACESv4="eth0"
INTERFACESv6=""
EOF
fi

# 4. File lease
mkdir -p /var/lib/dhcp
[ -f /var/lib/dhcp/dhcpd.leases ] || touch /var/lib/dhcp/dhcpd.leases

# 5. dhcpd.conf: ditulis ulang hanya jika belum memuat semua MAC, domain-search, dan domain-name kelompok
ADA=1
for M in $MAC_ITADORI $MAC_FUSHIGURO $MAC_ZENIN $MAC_OKKOTSU $MAC_INO $MAC_KUSAKABE $MAC_MIWA $MAC_KUGISAKI "$KELOMPOK.com" "option domain-name \"$KELOMPOK.com\""; do
  grep -q "$M" /etc/dhcp/dhcpd.conf 2>/dev/null || ADA=0
done

if [ "$ADA" = 0 ]; then
  service isc-dhcp-server stop >/dev/null 2>&1
  : > /var/lib/dhcp/dhcpd.leases   # kosongkan lease lama agar pengujian bersih
  cat <<EOF > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
authoritative;

option domain-search "$KELOMPOK.com";
option domain-name "$KELOMPOK.com";

# Class Network 2: Pool 1 (itadori, fushiguro) dan Pool 2 (zenin, okkotsu)
class "pool1" {
  match if (substring(hardware, 1, 6) = $MAC_ITADORI
         or substring(hardware, 1, 6) = $MAC_FUSHIGURO);
}

class "pool2" {
  match if (substring(hardware, 1, 6) = $MAC_ZENIN
         or substring(hardware, 1, 6) = $MAC_OKKOTSU);
}

# Class Network 3: short lease 30 menit (ino, kusakabe), long lease 12 jam (miwa)
class "short-lease" {
  match if (substring(hardware, 1, 6) = $MAC_INO
         or substring(hardware, 1, 6) = $MAC_KUSAKABE);
  default-lease-time 1800;
  max-lease-time 1800;
}

class "long-lease" {
  match if (substring(hardware, 1, 6) = $MAC_MIWA);
  default-lease-time 43200;
  max-lease-time 43200;
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
  option routers 10.74.3.1;
  option broadcast-address 10.74.3.255;
  option domain-name-servers 10.74.1.2, 10.74.1.3;

  pool {
    range 10.74.3.10 10.74.3.89;
    allow members of "short-lease";
  }

  pool {
    range 10.74.3.100 10.74.3.199;
    allow members of "long-lease";
  }

  # Static lease kugisaki (VIP): 10.74.3.99 berada di luar seluruh pool
  host kugisaki {
    hardware ethernet $MAC_KUGISAKI;
    fixed-address 10.74.3.99;
  }
}
EOF
fi

# 6. Daftarkan autostart DHCP Server
if [ -d /run/systemd/system ]; then
  systemctl enable isc-dhcp-server >/dev/null 2>&1
else
  update-rc.d isc-dhcp-server defaults >/dev/null 2>&1
fi

# 7. Validasi lalu jalankan service
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