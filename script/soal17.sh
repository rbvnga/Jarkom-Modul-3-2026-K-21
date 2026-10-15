upstream backend_cluster {
    # Weighted Round-Robin (nanami bobot 3, todo bobot 1)
    server 10.74.4.5 weight=3;
    server 10.74.4.6 weight=1;
    
    # Backup server jika semua worker utama down
    server 10.74.4.7 backup;
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://backend_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
# Definisikan zona cache proxy
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=1g inactive=60m use_temp_path=off;

# Definisikan rate limiting zone untuk /api (10 request per detik per IP)
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

server {
    listen 80;
    server_name _;

    # Konfigurasi Caching untuk halaman web frontend
    location / {
        proxy_pass http://10.74.4.2; # Mengarah ke internal proxy geto
        proxy_cache my_cache;
        proxy_cache_valid 200 302 10m;  # Cache HTTP 200 dan 302 selama 10 menit
        proxy_cache_valid 404 1m;
        
        # Tambahkan header X-Cache-Status
        add_header X-Cache-Status $upstream_cache_status;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Konfigurasi Rate Limiting untuk path /api
    location /api {
        limit_req zone=api_limit burst=20 nodelay;
        
        proxy_pass http://10.74.4.2; # Mengarah ke internal proxy geto
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
