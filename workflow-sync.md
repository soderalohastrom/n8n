# n8n Workflow Sync Guide

## Method 1: Built-in CLI Export/Import (Recommended)

### Export from local:
```bash
# Export all workflows
n8n export:workflow --all --output=./workflows-backup.json

# Export specific workflow
n8n export:workflow --id=<workflow-id> --output=./my-workflow.json

# Export with credentials (encrypted)
n8n export:credentials --all --output=./credentials-backup.json
```

### Import to Hostinger:
```bash
# SSH into Hostinger VPS
ssh root@your-hostinger-ip

# Import workflows
docker exec -i n8n-container n8n import:workflow --input=- < workflows-backup.json

# Import credentials
docker exec -i n8n-container n8n import:credentials --input=- < credentials-backup.json
```

## Method 2: n8n UI Export/Import

### Local Export:
1. Open workflow in n8n UI (http://localhost:5678)
2. Click workflow menu (3 dots) → "Download"
3. Save as JSON file

### Hostinger Import:
1. Access n8n on Hostinger (https://your-domain.com)
2. Click "Add workflow" → "Import from File"
3. Upload JSON file

## Method 3: API-based Sync

### Setup API access:
```bash
# On local n8n
export N8N_BASIC_AUTH_ACTIVE=true
export N8N_BASIC_AUTH_USER=admin
export N8N_BASIC_AUTH_PASSWORD=your-password
```

### Sync script:
```bash
#!/bin/bash
# sync-workflows.sh

LOCAL_URL="http://localhost:5678"
REMOTE_URL="https://your-n8n.hostinger.com"
AUTH_HEADER="Authorization: Basic $(echo -n 'admin:password' | base64)"

# Get all workflows from local
curl -H "$AUTH_HEADER" "$LOCAL_URL/api/v1/workflows" > local-workflows.json

# Push to remote (requires parsing and individual uploads)
# ... API implementation
```

## Method 4: Git-based Version Control

### Setup:
```bash
# Create workflows directory
mkdir -p ~/n8n-workflows
cd ~/n8n-workflows
git init

# Create export script
cat > export-workflows.sh << 'EOF'
#!/bin/bash
n8n export:workflow --all --output=./workflows/all-workflows.json
n8n export:workflow --all --separate --output=./workflows/
git add workflows/
git commit -m "Update workflows $(date +%Y-%m-%d)"
EOF

chmod +x export-workflows.sh
```

### Workflow:
1. Develop and test locally
2. Export workflows: `./export-workflows.sh`
3. Push to git repository
4. Pull on Hostinger and import

## Best Practices

### Testing Checklist:
- [ ] Test all workflow triggers
- [ ] Verify credential connections
- [ ] Check webhook URLs (will differ between environments)
- [ ] Test error handling paths
- [ ] Validate data transformations

### Environment Differences:
```javascript
// Use environment variables for URLs
const webhookUrl = process.env.WEBHOOK_URL || 'http://localhost:5678';
const apiEndpoint = process.env.API_ENDPOINT || 'https://api.example.com';
```

### Deployment Steps:
1. Export workflows from local
2. Update environment-specific settings
3. Import to Hostinger
4. Test all workflows
5. Update webhook URLs in external services