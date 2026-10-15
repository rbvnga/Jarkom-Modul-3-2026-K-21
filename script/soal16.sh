# Jalankan di node geto
cat << 'EOF' > /root/soal16_internal.sh
#!/bin/bash
dpkg -s nginx >/dev/null 2>&1 || { apt-get update >/dev/null 2>&1; apt-get install -y nginx >/dev/null 2>&1; }

rm -f /etc/nginx/sites-enabled/*

cat <<NGINXEOF > /etc/nginx/sites-available/geto
upstream api_workers {
    server 10.74.4.5;  # nanami
    server 10.74.4.6;  # todo
}

server {
    listen 80 default_server;
    server_name _;

    location / {
        proxy_pass http://api_workers;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
NGINXEOF

ln -sf /etc/nginx/sites-available/geto /etc/nginx/sites-enabled/geto
nginx -t && service nginx restart
echo "Internal proxy geto aktif."
EOF
chmod +x /root/soal16_internal.sh
./soal16_internal.sh
