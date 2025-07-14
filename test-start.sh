#!/bin/bash

# 简化测试脚本
echo "🧪 Testing Onlook startup..."

# 检查 bun
if ! command -v bun &> /dev/null; then
    echo "❌ Bun not installed. Installing..."
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
fi

# 创建环境文件
if [ ! -f ".env.local" ]; then
    echo "Creating .env.local..."
    cat > .env.local << 'EOF'
NODE_ENV=development
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=mock-key
SUPABASE_DATABASE_URL=postgresql://postgres:postgres@localhost:54322/postgres
CSB_API_KEY=mock-csb-api-key
NEXT_PUBLIC_SITE_URL=http://localhost:3000
ANTHROPIC_API_KEY=mock-anthropic-key
SKIP_ENV_VALIDATION=true
EOF
fi

# 复制环境文件
cp .env.local apps/web/client/.env.local

# 安装依赖
echo "📦 Installing dependencies..."
bun install

# 只启动前端进行测试
echo "🚀 Starting frontend only for testing..."
cd apps/web/client
bun run dev