# --- [SOAL 20] Apache Benchmark Audit (Kusakabe) ---
# Benchmark Baseline Homepage (600 request, concurrency 30)
ab -n 600 -c 30 http://10.74.1.4/

# Benchmark Endpoint /api dengan Rate Limiting Aktif
ab -n 600 -c 30 http://10.74.1.4/api
