# Jalankan di node terkait untuk memastikan resolusi host dasar
cat << 'EOF' > /root/soal11_network.sh
#!/bin/bash
echo "=== Setup Hostname dan Resolv ==="
echo "nameserver 192.168.122.1" > /etc/resolv.conf
hostnamectl set-hostname $(hostname)
echo "Network dasar siap."
EOF
chmod +x /root/soal11_network.sh
./soal11_network.sh
