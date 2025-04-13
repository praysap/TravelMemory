## Travel Memory Application
A full-stack travel memory journal web app built using the **MERN stack**, deployed on **AWS EC2**, and load-balanced with custom domain management via **Cloudflare**.

---
### Architecture diagram
![Architecture Diagram](https://github.com/praysap/TravelMemory/blob/main/assets/architecture.png)

---
## Tech Stack

- **Frontend**: React
- **Backend**: Node.js, Express
- **Database**: MongoDB Atlas
- **Cloud**: AWS EC2, Load Balancer, AMI, VPC
- **DNS**: Cloudflare
- **Web Server**: Nginx
---

### Prerequisites
1. Ensure backend IP is whitelisted in MongoDB Atlas.
2. All EC2 instances used were launched in us-east-1 (Mumbai) region.
3. Snapshots (AMIs) can be reused for creating instances & scailing.
---

## Quick Deployment Guide

### Backend Setup

1. Launch EC2 Instance (Linux) for backend setup.<br>
   Public IP - 54.167.66.211<br>
   ![Backend Setup](https://github.com/praysap/TravelMemory/blob/main/assets/backend_mern_stack.png)

3. Install Node.js and clone repo.
   ```bash
   # Download and install Node.js:
   sudo apt update
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt install -y nodejs

   # Install git and clone the repo
   sudo apt install git -y
   git clone https://github.com/UnpredictablePrashant/TravelMemory
   ```
4. Navigate to backend folder and create .env file and install the dependencies of the application.
   ```bash
   # Go to backend directory
   cd ~/TravelMemory/backend

   # Create .env file
   sudo nano .env

   # Put the following content (remember to change it based on your requirements)
   MONGO_URI=your_mongo_uri
   PORT=3000

   # Install & Build the dependencies & start node js application
   sudo npm install
   sudo npm pm2 -g
   pm2 start index.js
   ```

    
6. Setup Nginx reverse proxy on port 80.
   ```bash
   sudo apt install nginx -y
   sudo systemctl enable nginx
   sudo nano /etc/nginx/nginx.conf
   ```
   Example nginx config.
   ```bash
   server {
    listen 80;
    server_name api.zyanmonster.live;

    location / {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
   ```
   Restart & Reload nginx new config.
   ```bash
   sudo systemctl reload nginx
   sudo systemctl restart nginx
   sudo nginx -t #to validate nginx config file
   ```

---

### Frontend Setup

1. Launch separate EC2 instances (Linux) for frontend.<br>
   Public IP - 44.203.43.133<br>
   ![image](https://github.com/user-attachments/assets/b02f329a-7981-400f-8872-1b44fc39dbd8)

3. Install Node.js, clone the same repository.
   ```bash
   # Download and install Node.js:
   sudo apt update
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt install -y nodejs

   # Install git and clone the repo
   sudo apt install git -y
   git clone https://github.com/UnpredictablePrashant/TravelMemory
   ```
4. Navigate to frontend folder and create .env file and install the dependencies of the application.
   ```bash
   # Go to frontend directory
   cd ~/TravelMemory/frontend

   # create .env file
   sudo nano .env

   # Put the following content  
   REACT_APP_BACKEND_URL=https://api.zyanmonster.live

   # install the dependencies
   npm install
   ```
5. Update urls.js with backend IP or domain.
   ```bash
   # Go to frontend/src directory
   cd ~/TravelMemory/frontend/src
   
   # Put the following content (remember to change it based on your requirements): 
   export const baseUrl = process.env.REACT_APP_BACKEND_URL #Calling the value from .env file directy using variable "REACT_APP_BACKEND_URL"
   ```

7. Setup Nginx reverse proxy on port 80 for frontend just like backend.
   ```bash
   sudo apt install nginx -y
   sudo systemctl enable nginx
   sudo nano /etc/nginx/nginx.conf
   ```
   Example nginx config.
   ```bash
   server {
    listen 80;
    server_name zyanmonster.live;

    root /var/www/frontend;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
   ```
   Restart & Reload nginx new config.
   ```bash
   sudo systemctl reload nginx
   sudo systemctl restart nginx
   sudo nginx -t #to validate nginx config file
   ```
   Build  the application
   ```bash
   npm run build
   ```
---

### Load Balancing & Scaling

1. Create AMIs for both backend instances.<br>
   <img width="823" alt="image" src="https://github.com/user-attachments/assets/75af8ffc-001c-427d-997f-d1d09e5a2846" /><br>
2. Launch backend instances using these AMIs.<br>
   <img width="957" alt="image" src="https://github.com/user-attachments/assets/959d9791-9771-4fa9-aac4-3b26bb42a1af" /><br>
3. For Load Balancing, create Target Groups for backend.<br>
   <img width="429" alt="image" src="https://github.com/user-attachments/assets/dd9356cd-e1c2-42fc-9d43-3b13991fb37f" /><br>
   <img width="398" alt="image" src="https://github.com/user-attachments/assets/fd619d7f-ceb8-4fec-ad6e-020c45ca1c2b" /><br>
4. Create Application Load Balancers and assign target groups.<br>
   NOTE : Make sure the Load balancer is mapped to multi AZs
   <img width="959" alt="image" src="https://github.com/user-attachments/assets/d737c3c2-d550-48b0-8821-13bf94450d4a" /><br>
   ![image](https://github.com/user-attachments/assets/b5a9b575-d518-423c-aa21-425d820da886)<br>
---

### Custom Domain Setup Using Cloudflare

1. Connect your domain & sudomain to the application using Cloudflare.<br> 
   e.g. - Domain: zynamonster.live<br>
   e.g. - Subdomain: api.zyanmonster.live<br>
   
2. Create a CNAME record pointing to the load balancer endpoint.<br>
   <img width="446" alt="image" src="https://github.com/user-attachments/assets/36cab0cd-c2c6-4c7a-b60d-f65bb64bca30" />


4. Now we can access the application using domain name because of DNS settings.<br>
   ![image](https://github.com/user-attachments/assets/f12ae51c-e6ed-4e85-bb9f-41fa3911672d)<br>

   Click on "Add Experience" and enter new data through UI.<br>
   <img width="956" alt="image" src="https://github.com/user-attachments/assets/4d37bc15-44a2-4c4a-af48-a2d4630c58f6" /><br>
   
   The data get stored in the MongoDB database.<br>
   ![image](https://github.com/user-attachments/assets/35a49355-3ec9-4dd5-8c9a-8f520830fc55)
---


