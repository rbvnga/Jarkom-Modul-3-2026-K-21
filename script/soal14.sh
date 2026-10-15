# Jalankan di node maki dan panda
cat << 'EOF' > /root/soal14_frontend.sh
#!/bin/bash
DOMAIN="jujutsu.K-21.com"

dpkg -s nginx >/dev/null 2>&1 || { apt-get update >/dev/null 2>&1; apt-get install -y nginx >/dev/null 2>&1; }

mkdir -p /var/www/html
HOST_NAME=$(hostname)

cat <<HTML > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head><title>Jujutsu Platform - $HOST_NAME</title></head>
<body>
  <h1>Welcome to Jujutsu Platform</h1>
  <p>Served from frontend node: <strong>$HOST_NAME</strong></p>
</body>
</html>
HTML

chown -R www-data:www-data /var/www/html

cat <<NGINXEOF > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    server_name $DOMAIN www.$DOMAIN _;
    root /var/www/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
NGINXEOF

nginx -t && service nginx restart
echo "Frontend node $HOST_NAME siap."
EOF
chmod +x /root/soal14_frontend.sh
./soal14_frontend.sh
