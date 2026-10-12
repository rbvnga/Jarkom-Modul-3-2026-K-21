# ISI SETIAP /etc/network/interfaces DEBINET

# JINCHI 
auto eth0
iface eth0 inet dhcp
up sysctl -w net.ipv4.ip_forward=1
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.74.0.0/16

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


apt update && apt install -y iptables  
iptables -t nat -A POSTROUTING -o eth0 -s 10.74.0.0/16 -j MASQUERADE

# JICHI DAN SEMUA DEBINET LAIN 
cat <<EOF > /root/.bashrc
echo "nameserver 192.168.122.1" >> /etc/resolv.conf
EOF



# UTAHIME
auto eth0
iface eth0 inet static
  address 10.74.1.2
  netmask 255.255.255.0
  gateway 10.74.1.1

# SHOKO
auto eth0
iface eth0 inet static
  address 10.74.1.3
  netmask 255.255.255.0
  gateway 10.74.1.1

# GOJO
auto eth0
iface eth0 inet static
  address 10.74.1.4
  netmask 255.255.255.0
  gateway 10.74.1.1

# GETO
auto eth0
iface eth0 inet static
  address 10.74.4.2
  netmask 255.255.255.0
  gateway 10.74.4.1

# MAKI
iface eth0 inet static
  address 10.74.4.3
  netmask 255.255.255.0
  gateway 10.74.4.1

# PANDA
iface eth0 inet static
  address 10.74.4.4
  netmask 255.255.255.0
  gateway 10.74.4.1

# NANAMI
iface eth0 inet static
  address 10.74.4.5
  netmask 255.255.255.0
  gateway 10.74.4.1

# TODO
iface eth0 inet static
  address 10.74.4.6
  netmask 255.255.255.0
  gateway 10.74.4.1

# KIRARA
iface eth0 inet static
  address 10.74.4.7
  netmask 255.255.255.0
  gateway 10.74.4.1

# INUMAKI
auto eth0
iface eth0 inet static
  address 10.74.4.8
  netmask 255.255.255.0
  gateway 10.74.4.1

# YAGA
auto eth0
iface eth0 inet static
  address 10.74.4.9
  netmask 255.255.255.0
  gateway 10.74.4.1

# TENGEN
auto eth0
iface eth0 inet static
  address 10.74.4.10
  netmask 255.255.255.0
  gateway 10.74.4.1


# tes di jichi
ping -c 2 10.74.1.1
ping -c 2 10.74.2.1
ping -c 2 10.74.3.1
ping -c 2 10.74.4.1
ping -c 2 8.8.8.8
ping -c 2 google.com

# Tes dari todo
ping -c 2 10.74.4.1     # gateway
ping -c 2 8.8.8.8       # akses eksternal melalui NAT
ping -c 2 google.com    # resolusi DNS