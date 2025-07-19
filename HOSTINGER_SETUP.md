# Hostinger n8n Setup Guide

## Your VPS Details
- **IP Address:** `31.97.147.252`
- **SSH Access:** `ssh root@31.97.147.252`
- **n8n URL:** `https://n8n.srv916063.hstgr.cloud`
- **VPS Hostname:** `srv916063.hstgr.cloud`

## First-Time Setup Steps

### 1. Access Your n8n Instance
1. **Primary URL:** `https://n8n.srv916063.hstgr.cloud`
2. Click "Manage App" button in your Hostinger dashboard
3. Note: Direct IP access won't work due to Traefik reverse proxy

### 2. Create Admin Account
- First visit will prompt for admin account creation
- Choose strong credentials - this controls your entire n8n instance

### 3. Test SSH Access
```bash
ssh root@31.97.147.252
```

### 4. Locate n8n Docker Setup
```bash
# On your VPS, find the docker-compose.yml
ls -la /root/
cat /root/docker-compose.yml

# Check running containers
docker ps
```

### 5. Configure Your Sync Script
```bash
# No environment variables needed - IP is hardcoded
cd /Users/soderstrom/n8n
./scripts/n8n-sync.sh
```

## Daily Workflow

### Local Development:
```bash
cd /Users/soderstrom/n8n
pnpm start
# Develop at http://localhost:5678
```

### Deploy to Hostinger:
```bash
./scripts/n8n-sync.sh  # Choose option 3
```

### Verify Deployment:
- Visit your Hostinger n8n URL
- Check workflows imported correctly
- Test any webhooks/triggers

## Important Notes

### Docker Commands on Hostinger:
```bash
# Update n8n
docker compose pull
docker compose down
docker compose up -d

# Check logs
docker logs n8n

# Import workflows manually
docker exec -i n8n n8n import:workflow --input=- < workflows.json
```

### Environment Variables:
- Edit `/root/docker-compose.yml` for configuration
- Common variables: `N8N_HOST`, `N8N_PORT`, `WEBHOOK_URL`

### Webhook URLs:
- Local: `http://localhost:5678/webhook/...`
- Hostinger: `https://n8n.srv916063.hstgr.cloud/webhook/...`
- Update external services when deploying

## Troubleshooting

### Can't Access n8n Web Interface:
1. Use exact URL: `https://n8n.srv916063.hstgr.cloud`
2. Check SSL certificate is valid (may take a few minutes)
3. SSH in and check `docker ps` and `docker logs root-n8n-1`

### SSH Connection Issues:
1. Verify IP: `31.97.147.252`
2. Use root user: `ssh root@31.97.147.252`
3. Check VPS status in Hostinger dashboard

### Workflow Import Fails:
1. Check n8n version compatibility
2. Verify JSON format
3. Import credentials separately if needed

## Next Steps
1. Access your n8n instance via Hostinger dashboard
2. Create your first workflow
3. Test the sync script with a simple workflow
4. Set up any required webhook URLs in external services