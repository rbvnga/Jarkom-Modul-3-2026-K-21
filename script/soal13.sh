# Jalankan di node yaga
cat << 'EOF' > /root/soal13_database.sh
#!/bin/bash
DB_NAME="db_shibuya_K-21"
DB_USER="user_shibuya"
DB_PASS="password123"

service mariadb start >/dev/null 2>&1 || service mysql start >/dev/null 2>&1

mysql -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;"
mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'\%' IDENTIFIED BY '$DB_PASS';"
mysql -e "GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';"
mysql -e "FLUSH PRIVILEGES;"

echo "Database $DB_NAME dan user$DB_USER berhasil disiapkan."
EOF
chmod +x /root/soal13_database.sh
./soal13_database.sh
