#!/bin/bash
# === System Update ===
apt-get update

# === Install Node.js v22 ===
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
apt-get install -y nodejs

# === Install Nginx ===
apt-get install -y nginx

# === Set permission ===
cd /var/www/
chmod -R 775 /var/www/

# === Clone Backend Repo to /var/www ===
git clone https://github.com/psagar-dev/travel-memory-hv.git travel-memory
cd travel-memory/backend

# === Create .env File & put data ===
echo "PORT=3000" > .env
echo "MONGO_URI='Your Mongo URl'" >> .env

# === Install App Dependencies & PM2 ===
npm install
npm install pm2 -g
pm2 start index.js --name "travel-memory-backend"
pm2 startup
pm2 save

# === Configure Nginx ===
rm /etc/nginx/sites-enabled/default
bash -c 'cat > /etc/nginx/sites-available/travel-memory << EOF
server {
    listen 80;
    server_name _;
    root /var/www/html;
    index index.html index.nginx-debian.html;
    location / {
        try_files \$uri \$uri/ /index.html;
    }
    location /api/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF'

ln -s /etc/nginx/sites-available/travel-memory /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
systemctl restart nginx