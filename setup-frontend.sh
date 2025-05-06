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
cd travel-memory/frontend

# === Create .env File & put data ===
echo "REACT_APP_BACKEND_URL=http://tmapi.example.com" > .env

# === Install App Dependencies ===
npm install
npm run build

# === Copy Build Output to /var/www/html ===
rm -rf /var/www/html/*
cp -r build/* /var/www/html/

# === Configure Nginx for Static Site ===
rm -f /etc/nginx/sites-enabled/default
bash -c 'cat > /etc/nginx/sites-available/tm.example.com << EOF
server {
    listen 80;
    server_name _;

    root /var/www/html;
    index index.html;

    location ~ /\.(?!well-known).* {
        deny all;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
EOF'

ln -s /etc/nginx/sites-available/tm.patelsagar.com /etc/nginx/sites-enabled/

nginx -t
systemctl reload nginx
systemctl restart nginx