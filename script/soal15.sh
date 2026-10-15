# Jalankan di node gojo
cat << 'EOF' > /root/soal15_proxy.sh
#!/bin/bash
DOMAIN="jujutsu.K-21.com"

dpkg -s nginx >/dev/null 2>&1 || { apt-get update >/dev/null 2>&1; apt-get install -y nginx >/dev/null 2>&1; }

rm -f /etc/nginx/sites-enabled/*

cat <<NGINXEOF > /etc/nginx/sites-available/gojo
upstream web_frontend {
    server 10.74.4.3;  # maki
    server 10.74.4.4;  # panda
}

server {
    listen 80 default_server;
    server_name $DOMAIN www.$DOMAIN;

    location / {
        proxy_pass http://web_frontend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
NGINXEOF

ln -sf /etc/nginx/sites-available/gojo /etc/nginx/sites-enabled/gojo
nginx -t && service nginx restart
echo "Public proxy gojo aktif."
EOF
chmod +x /root/soal15_proxy.sh
./soal15_proxy.sh
