# Jalankan di node klien (misal: itadori / kusakabe)
cat << 'EOF' > /root/soal12_dns.sh
#!/bin/bash
DOMAIN="jujutsu.K-21.com"
GOJO_IP="10.74.1.4"

# Tambahkan pemetaan domain ke /etc/hosts jika belum ada DNS server lokal
if ! grep -q "$DOMAIN" /etc/hosts; then
  echo "$GOJO_IP $DOMAIN www.$DOMAIN" >> /etc/hosts
  echo "Domain $DOMAIN berhasil dipetakan ke $GOJO_IP"
else
  echo "Domain sudah ada di /etc/hosts"
fi
EOF
chmod +x /root/soal12_dns.sh
./soal12_dns.sh
