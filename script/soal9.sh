# Catat kondisi normal (sebelum gangguan)
# JICHI
date
ps aux | grep '[d]hcrelay'

# ITADORI
ip -4 a show eth0
ip route

# Matikan relay di jichi
service isc-dhcp-relay stop
pkill dhcrelay
ps aux | grep '[d]hcrelay'

# Cek di ITADORI setelah di matikan
date
ip addr flush dev eth0
udhcpc -i eth0 -n -t 3
ip -4 a show eth0
ip route


# MEMULIHKAN JICHI
service isc-dhcp-relay start
ps aux | grep '[d]hcrelay'

# cek kembali di ITADORI
date
udhcpc -i eth0
ip -4 a show eth0
ip route
