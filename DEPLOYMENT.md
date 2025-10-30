# Deployment Guide

This guide covers multiple deployment options for your authentication application.

## Table of Contents
1. [Supabase Setup](#supabase-setup)
2. [Local Development](#local-development)
3. [AWS Deployment (Recommended)](#aws-deployment)
4. [GCP Deployment](#gcp-deployment)
5. [OCI Deployment](#oci-deployment)
6. [Vercel Frontend Deployment](#vercel-frontend-deployment)
7. [Backend Hosting Options](#backend-hosting-options)

---

## Supabase Setup

### 1. Create a Supabase Project
1. Go to [supabase.com](https://supabase.com) and sign up
2. Create a new project
3. Wait for the database to be provisioned

### 2. Run the Database Setup Script
1. Go to the SQL Editor in your Supabase dashboard
2. Copy the contents of `supabase-setup.sql`
3. Paste and run the script
4. This will create:
   - `users` table
   - `sign_in_attempts` table
   - Indexes for performance
   - Row Level Security policies

### 3. Get Your Credentials
- **Project URL**: Found in Settings → API
- **Anon/Public Key**: Found in Settings → API (for frontend)
- **Service Role Key**: Found in Settings → API (for backend - keep this secret!)

---

## Local Development

### Prerequisites
- Node.js 20+ installed
- Docker and Docker Compose (optional)

### Option 1: Without Docker

#### Backend Setup
```bash
cd backend
cp .env.example .env
# Edit .env and add your Supabase credentials
npm install
npm run start:dev
```

#### Frontend Setup
```bash
cd frontend
cp .env.example .env
# Edit .env and add your Supabase credentials
npm install
npm run dev
```

### Option 2: With Docker

```bash
# In the root directory
cp .env.example .env
# Edit .env and add your credentials
docker-compose up --build
```

Access the application:
- Frontend: http://localhost:3000
- Backend: http://localhost:3001

---

## AWS Deployment

### Prerequisites
- AWS Account
- AWS CLI installed and configured

### Step 1: Launch an EC2 Instance

1. **Launch Ubuntu Instance**
   ```bash
   # Choose Ubuntu Server 22.04 LTS
   # Instance type: t2.medium or t3.medium (minimum)
   # Storage: 20 GB
   ```

2. **Configure Security Group**
   - Allow SSH (port 22) from your IP
   - Allow HTTP (port 80) from anywhere
   - Allow HTTPS (port 443) from anywhere
   - Allow Custom TCP (port 3000) from anywhere (frontend)
   - Allow Custom TCP (port 3001) from anywhere (backend)

### Step 2: Connect to Your Instance

```bash
ssh -i your-key.pem ubuntu@your-instance-ip
```

### Step 3: Install Docker and Docker Compose

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version

# Logout and login again for group changes to take effect
exit
```

### Step 4: Deploy Your Application

```bash
# Reconnect to the instance
ssh -i your-key.pem ubuntu@your-instance-ip

# Clone your repository or upload files
# If using Git:
git clone your-repository-url
cd your-project

# If uploading files manually:
# Use scp or SFTP to upload the project

# Create .env file
nano .env
# Add your environment variables (Supabase credentials, etc.)

# Build and run with Docker Compose
docker-compose up -d --build

# Check logs
docker-compose logs -f
```

### Step 5: Set Up Nginx as Reverse Proxy (Optional but Recommended)

```bash
# Install Nginx
sudo apt install nginx -y

# Create Nginx configuration
sudo nano /etc/nginx/sites-available/auth-app

# Add the following configuration:
```

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # Frontend
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Backend API
    location /api {
        rewrite ^/api(.*)$ $1 break;
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Enable the site
sudo ln -s /etc/nginx/sites-available/auth-app /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

### Step 6: Set Up SSL with Let's Encrypt (Recommended)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get SSL certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal is set up automatically
```

---

## GCP Deployment

### Prerequisites
- Google Cloud Platform account
- gcloud CLI installed

### Step 1: Create a Compute Engine Instance

```bash
# Create instance
gcloud compute instances create auth-app-instance \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=e2-medium \
  --boot-disk-size=20GB \
  --zone=us-central1-a

# Create firewall rules
gcloud compute firewall-rules create allow-http \
  --allow tcp:80 \
  --source-ranges 0.0.0.0/0 \
  --target-tags http-server

gcloud compute firewall-rules create allow-https \
  --allow tcp:443 \
  --source-ranges 0.0.0.0/0 \
  --target-tags https-server

gcloud compute firewall-rules create allow-app \
  --allow tcp:3000,tcp:3001 \
  --source-ranges 0.0.0.0/0
```

### Step 2: SSH into Instance

```bash
gcloud compute ssh auth-app-instance --zone=us-central1-a
```

### Step 3: Follow the same installation steps as AWS
(Docker, Docker Compose, application deployment, Nginx setup)

---

## OCI Deployment

### Prerequisites
- Oracle Cloud Infrastructure account

### Step 1: Create a Compute Instance

1. Go to OCI Console → Compute → Instances
2. Click "Create Instance"
3. Choose:
   - Image: Ubuntu 22.04
   - Shape: VM.Standard.E2.1.Micro (Free tier) or higher
   - Add SSH key
4. Configure networking to allow ports 22, 80, 443, 3000, 3001

### Step 2: Configure Security Lists

1. Go to Virtual Cloud Networks → Your VCN → Security Lists
2. Add Ingress Rules:
   - Port 80 (HTTP)
   - Port 443 (HTTPS)
   - Port 3000 (Frontend)
   - Port 3001 (Backend)

### Step 3: Connect and Deploy

```bash
ssh -i your-key ubuntu@your-instance-ip
```

Follow the same installation steps as AWS.

---

## Vercel Frontend Deployment

Vercel is excellent for hosting the SvelteKit frontend.

### Step 1: Prepare Your Frontend

1. Update `frontend/svelte.config.js` to use the Vercel adapter:

```bash
cd frontend
npm install -D @sveltejs/adapter-vercel
```

Update `svelte.config.js`:
```javascript
import adapter from '@sveltejs/adapter-vercel';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
  preprocess: vitePreprocess(),
  kit: {
    adapter: adapter()
  }
};

export default config;
```

### Step 2: Deploy to Vercel

```bash
# Install Vercel CLI
npm install -g vercel

# Login
vercel login

# Deploy
cd frontend
vercel
```

### Step 3: Configure Environment Variables in Vercel

1. Go to your project in Vercel Dashboard
2. Settings → Environment Variables
3. Add:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
   - `VITE_BACKEND_URL` (your backend URL)

### Step 4: Update CORS in Backend

Update your backend's CORS configuration to include your Vercel URL:

```typescript
// backend/src/main.ts
app.enableCors({
  origin: ['http://localhost:5173', 'https://your-app.vercel.app'],
  credentials: true,
});
```

---

## Backend Hosting Options

### Option 1: Railway

1. Go to [railway.app](https://railway.app)
2. Create a new project
3. Deploy from GitHub
4. Add environment variables
5. Railway will automatically detect NestJS and deploy

### Option 2: Render

1. Go to [render.com](https://render.com)
2. Create new Web Service
3. Connect your repository
4. Configure:
   - Build command: `cd backend && npm install && npm run build`
   - Start command: `cd backend && npm run start:prod`
5. Add environment variables

### Option 3: Heroku

```bash
# Install Heroku CLI
# Login
heroku login

# Create app
heroku create your-backend-app

# Add buildpack
heroku buildpacks:set heroku/nodejs

# Create Procfile in backend directory
echo "web: npm run start:prod" > backend/Procfile

# Deploy
cd backend
git init
git add .
git commit -m "Initial commit"
heroku git:remote -a your-backend-app
git push heroku main

# Set environment variables
heroku config:set SUPABASE_URL=your_url
heroku config:set SUPABASE_KEY=your_key
heroku config:set JWT_SECRET=your_secret
```

### Option 4: DigitalOcean App Platform

1. Go to DigitalOcean App Platform
2. Create new app from GitHub
3. Configure:
   - Source: Your backend directory
   - Build command: `npm install && npm run build`
   - Run command: `npm run start:prod`
4. Add environment variables

---

## Environment Variables Reference

### Frontend (.env)
```env
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
VITE_BACKEND_URL=http://your-backend-url:3001
```

### Backend (.env)
```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_KEY=your_supabase_service_role_key
JWT_SECRET=your_jwt_secret_key
PORT=3001
```

---

## Production Checklist

- [ ] Supabase database is set up with proper schema
- [ ] Environment variables are configured (never commit .env files!)
- [ ] CORS is properly configured in backend
- [ ] SSL certificates are installed (HTTPS)
- [ ] Firewall rules are configured correctly
- [ ] Docker containers are running and healthy
- [ ] Database backups are configured
- [ ] Monitoring is set up (optional: CloudWatch, Datadog, etc.)
- [ ] Domain name is pointed to your server
- [ ] Password policies are enforced
- [ ] Rate limiting is implemented (optional enhancement)

---

## Troubleshooting

### Frontend can't connect to backend
- Check CORS configuration
- Verify VITE_BACKEND_URL is correct
- Ensure backend is running and accessible

### Docker containers won't start
- Check logs: `docker-compose logs`
- Verify .env file exists and has correct values
- Ensure ports aren't already in use

### Database connection fails
- Verify Supabase credentials
- Check if Supabase project is active
- Ensure database schema is properly set up

### IP geolocation not working
- The app uses ipapi.co which has rate limits
- Consider upgrading to a paid plan or using alternative services

---

## Monitoring and Maintenance

### View Docker Logs
```bash
docker-compose logs -f
docker-compose logs frontend
docker-compose logs backend
```

### Restart Services
```bash
docker-compose restart
docker-compose restart frontend
docker-compose restart backend
```

### Update Application
```bash
git pull
docker-compose down
docker-compose up -d --build
```

### Backup Supabase Data
Use Supabase's built-in backup features or set up automated PostgreSQL backups.

---

## Cost Estimates

### AWS (t3.medium instance)
- EC2 Instance: ~$30-40/month
- Bandwidth: Variable
- Total: ~$40-60/month

### GCP (e2-medium)
- Compute Engine: ~$25-35/month
- Bandwidth: Variable
- Total: ~$35-50/month

### OCI Free Tier
- 2 VM instances (free forever)
- Limited resources but sufficient for small apps
- Total: $0

### Vercel + Railway/Render
- Vercel Frontend: Free for hobby projects
- Railway/Render Backend: ~$5-20/month
- Total: ~$5-20/month

### Supabase
- Free tier: 500MB database, 2GB bandwidth
- Pro tier: $25/month for larger projects

---

## Support

For issues or questions:
- Check the GitHub repository issues
- Review Supabase documentation
- Check SvelteKit and NestJS documentation
