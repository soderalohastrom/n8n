#!/bin/bash
# Quick start script for local n8n development

set -e

echo "🔧 Setting up Node.js v20.18.1..."
export PATH="$NVM_DIR/versions/node/v20.18.1/bin:$PATH"

echo "📦 Node version: $(node --version)"
echo "📦 npm version: $(npm --version)"

echo "🚀 Setting up environment variables..."
export N8N_RUNNERS_ENABLED=true
export N8N_USER_FOLDER=~/.n8n
export N8N_ENCRYPTION_KEY="n8n8n8n"

echo "📍 Environment:"
echo "   - Task runners: enabled"
echo "   - Data folder: ~/.n8n"
echo "   - Fresh installation"

echo ""
echo "🚀 Starting n8n via npx..."
echo "📍 This will install n8n v1.97.1 and start it"
echo "🌐 Access: http://localhost:5678"
echo ""

npx n8n