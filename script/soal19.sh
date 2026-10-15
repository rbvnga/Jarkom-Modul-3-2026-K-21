# --- [SOAL 19] Uji Proxy Caching & Rate Limiting ---
# Cek Status Cache (Akses awal MISS, akses berikutnya HIT)
curl -I http://10.74.1.4/

# Uji Rate Limiting pada path /api (Memicu status 503 setelah melewati burst)
for i in $(seq 1 30); do curl -s -o /dev/null -w "%{http_code}\n" http://10.74.1.4/api; done
