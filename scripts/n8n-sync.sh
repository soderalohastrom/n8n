#!/bin/bash
# n8n Workflow Sync Script
# Syncs n8n workflows between local and Hostinger

set -e

# Configuration
LOCAL_N8N_PATH="/Users/soderstrom/n8n"
EXPORT_DIR="$LOCAL_N8N_PATH/workflow-exports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
HOSTINGER_IP="31.97.147.252"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Create export directory
mkdir -p "$EXPORT_DIR"

# Function to export workflows
export_workflows() {
    echo -e "${YELLOW}Exporting workflows...${NC}"
    
    # Export all workflows as single file
    npx n8n export:workflow --all --output="$EXPORT_DIR/all-workflows-$TIMESTAMP.json"
    
    # Export workflows separately for version control
    npx n8n export:workflow --all --separate --output="$EXPORT_DIR/individual/"
    
    echo -e "${GREEN}✓ Workflows exported to $EXPORT_DIR${NC}"
}

# Function to export credentials
export_credentials() {
    echo -e "${YELLOW}Exporting credentials...${NC}"
    
    npx n8n export:credentials --all --output="$EXPORT_DIR/credentials-$TIMESTAMP.json"
    
    echo -e "${GREEN}✓ Credentials exported (encrypted)${NC}"
}

# Function to create deployment package
create_deployment_package() {
    echo -e "${YELLOW}Creating deployment package...${NC}"
    
    cd "$EXPORT_DIR"
    tar -czf "n8n-deployment-$TIMESTAMP.tar.gz" \
        "all-workflows-$TIMESTAMP.json" \
        "credentials-$TIMESTAMP.json" \
        "individual/"
    
    echo -e "${GREEN}✓ Deployment package created: n8n-deployment-$TIMESTAMP.tar.gz${NC}"
}

# Function to deploy to Hostinger
deploy_to_hostinger() {
    HOSTINGER_HOST="${HOSTINGER_HOST:-$HOSTINGER_IP}"
    
    echo -e "${YELLOW}Deploying to Hostinger ($HOSTINGER_HOST)...${NC}"
    
    # Copy package to Hostinger
    scp "$EXPORT_DIR/n8n-deployment-$TIMESTAMP.tar.gz" "root@$HOSTINGER_HOST:/tmp/"
    
    # Import on Hostinger
    ssh "root@$HOSTINGER_HOST" << EOF
        cd /tmp
        tar -xzf n8n-deployment-$TIMESTAMP.tar.gz
        
        # Import workflows
        docker exec -i root-n8n-1 n8n import:workflow --input=- < all-workflows-$TIMESTAMP.json
        
        # Import credentials (optional, requires confirmation)
        echo "Run this to import credentials:"
        echo "docker exec -i root-n8n-1 n8n import:credentials --input=- < /tmp/credentials-$TIMESTAMP.json"
        
        # Cleanup
        rm n8n-deployment-$TIMESTAMP.tar.gz
EOF
    
    echo -e "${GREEN}✓ Deployment complete!${NC}"
}

# Main menu
echo "n8n Workflow Sync Tool"
echo "====================="
echo "1. Export workflows only"
echo "2. Export workflows and credentials"
echo "3. Export and deploy to Hostinger"
echo "4. Git commit workflow changes"

read -p "Select option (1-4): " choice

case $choice in
    1)
        export_workflows
        ;;
    2)
        export_workflows
        export_credentials
        ;;
    3)
        export_workflows
        export_credentials
        create_deployment_package
        deploy_to_hostinger
        ;;
    4)
        export_workflows
        cd "$EXPORT_DIR"
        git add individual/
        git commit -m "Update workflows - $TIMESTAMP"
        echo -e "${GREEN}✓ Changes committed to git${NC}"
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo -e "\n${GREEN}Done! Workflows location: $EXPORT_DIR${NC}"