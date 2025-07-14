#!/bin/bash

# Onlook 项目一键启动脚本
# 此脚本用于启动所有必要的服务

echo "🚀 Starting Onlook Services..."

# 设置颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查 bun 是否安装
if ! command -v bun &> /dev/null; then
    echo -e "${RED}❌ Error: bun is not installed${NC}"
    echo "Please install bun first: curl -fsSL https://bun.sh/install | bash"
    exit 1
fi

# 创建日志目录
mkdir -p logs

# 检查并创建环境变量文件
if [ ! -f ".env.local" ]; then
    echo -e "${YELLOW}⚠️  Creating .env.local file with mock data...${NC}"
    cat > .env.local << 'EOF'
# Mock environment variables for local development
NODE_ENV=development

# Supabase (Mock)
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
SUPABASE_DATABASE_URL=postgresql://postgres:postgres@localhost:54322/postgres

# CodeSandbox
CSB_API_KEY=mock-csb-api-key

# Site URL
NEXT_PUBLIC_SITE_URL=http://localhost:3000

# AI API Keys (you'll need to add real keys for AI features)
ANTHROPIC_API_KEY=mock-anthropic-key
GOOGLE_AI_STUDIO_API_KEY=mock-google-key
OPENAI_API_KEY=mock-openai-key

# Optional services (mock)
RESEND_API_KEY=mock-resend-key
FREESTYLE_API_KEY=mock-freestyle-key
NEXT_PUBLIC_HOSTING_DOMAIN=localhost

# Features
NEXT_PUBLIC_FEATURE_COLLABORATION=false

# Skip environment validation for missing optional vars
SKIP_ENV_VALIDATION=true
EOF
    echo -e "${GREEN}✅ Created .env.local with mock data${NC}"
fi

# 复制环境变量到各个应用
echo -e "${YELLOW}📋 Copying environment variables...${NC}"
cp .env.local apps/web/client/.env.local 2>/dev/null || true
cp .env.local apps/web/server/.env.local 2>/dev/null || true
cp .env.local apps/backend/.env.local 2>/dev/null || true

# 安装依赖
echo -e "${YELLOW}📦 Installing dependencies...${NC}"
bun install

# 启动 Supabase (如果使用 Docker)
if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}🐳 Starting Supabase with Docker...${NC}"
    cd apps/backend
    docker run -d \
        --name supabase-db \
        -p 54322:5432 \
        -e POSTGRES_PASSWORD=postgres \
        -e POSTGRES_DB=postgres \
        postgres:15 2>/dev/null || echo "Supabase DB container already running"
    cd ../..
else
    echo -e "${YELLOW}⚠️  Docker not found, skipping Supabase setup${NC}"
fi

# 启动各个服务
echo -e "${GREEN}🚀 Starting services...${NC}"

# 启动后端服务器
echo -e "${YELLOW}Starting backend server...${NC}"
(cd apps/web/server && bun run dev > ../../logs/server.log 2>&1) &
SERVER_PID=$!
echo "Backend server PID: $SERVER_PID"

# 启动预加载服务
echo -e "${YELLOW}Starting preload service...${NC}"
(cd apps/web/preload && bun run server/index.ts > ../../logs/preload.log 2>&1) &
PRELOAD_PID=$!
echo "Preload service PID: $PRELOAD_PID"

# 启动模板服务
echo -e "${YELLOW}Starting template service...${NC}"
(cd apps/web/template && bun run dev > ../../logs/template.log 2>&1) &
TEMPLATE_PID=$!
echo "Template service PID: $TEMPLATE_PID"

# 等待服务启动
sleep 5

# 启动前端客户端（前台运行）
echo -e "${GREEN}🌐 Starting frontend client...${NC}"
echo -e "${YELLOW}The frontend will be available at: http://localhost:3000${NC}"
echo ""
echo "Service PIDs:"
echo "- Backend Server: $SERVER_PID"
echo "- Preload Service: $PRELOAD_PID"
echo "- Template Service: $TEMPLATE_PID"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop all services${NC}"
echo ""

# 创建停止脚本
cat > stop-all-services.sh << EOF
#!/bin/bash
echo "Stopping all services..."
kill $SERVER_PID 2>/dev/null
kill $PRELOAD_PID 2>/dev/null
kill $TEMPLATE_PID 2>/dev/null
pkill -f "bun.*dev" 2>/dev/null
docker stop supabase-db 2>/dev/null
echo "All services stopped"
EOF
chmod +x stop-all-services.sh

# 启动前端（前台运行，这样可以看到输出）
cd apps/web/client
bun run dev

# 清理（当用户按 Ctrl+C 时）
trap 'echo -e "\n${YELLOW}Stopping all services...${NC}"; ./stop-all-services.sh; exit' INT