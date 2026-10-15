# --- [SOAL 18] Uji Failover ke Kirara ---
# 1. Matikan worker utama (nanami & todo)
# service nginx stop (jalankan di nanami & todo)

# 2. Uji request dari itadori untuk memastikan beralih ke kirara
for i in $(seq 1 4); do curl -s http://10.74.4.2/; echo ""; done
