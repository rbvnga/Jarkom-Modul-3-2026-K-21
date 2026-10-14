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

