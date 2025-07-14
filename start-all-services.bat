@echo off
REM Onlook 项目一键启动脚本 (Windows)
REM 此脚本用于启动所有必要的服务

echo Starting Onlook Services...

REM 检查 bun 是否安装
where bun >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: bun is not installed
    echo Please install bun first from https://bun.sh
    echo Run: powershell -c "irm bun.sh/install.ps1 | iex"
    pause
    exit /b 1
)

REM 创建日志目录
if not exist logs mkdir logs

REM 检查并创建环境变量文件
if not exist ".env.local" (
    echo Creating .env.local file with mock data...
    (
        echo # Mock environment variables for local development
        echo NODE_ENV=development
        echo.
        echo # Supabase ^(Mock^)
        echo NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
        echo NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
        echo SUPABASE_DATABASE_URL=postgresql://postgres:postgres@localhost:54322/postgres
        echo.
        echo # CodeSandbox
        echo CSB_API_KEY=mock-csb-api-key
        echo.
        echo # Site URL
        echo NEXT_PUBLIC_SITE_URL=http://localhost:3000
        echo.
        echo # AI API Keys ^(you'll need to add real keys for AI features^)
        echo ANTHROPIC_API_KEY=mock-anthropic-key
        echo GOOGLE_AI_STUDIO_API_KEY=mock-google-key
        echo OPENAI_API_KEY=mock-openai-key
        echo.
        echo # Optional services ^(mock^)
        echo RESEND_API_KEY=mock-resend-key
        echo FREESTYLE_API_KEY=mock-freestyle-key
        echo NEXT_PUBLIC_HOSTING_DOMAIN=localhost
        echo.
        echo # Features
        echo NEXT_PUBLIC_FEATURE_COLLABORATION=false
        echo.
        echo # Skip environment validation for missing optional vars
        echo SKIP_ENV_VALIDATION=true
    ) > .env.local
    echo Created .env.local with mock data
)

REM 复制环境变量到各个应用
echo Copying environment variables...
copy .env.local apps\web\client\.env.local >nul 2>&1
copy .env.local apps\web\server\.env.local >nul 2>&1
copy .env.local apps\backend\.env.local >nul 2>&1

REM 安装依赖
echo Installing dependencies...
call bun install

REM 启动 Supabase (如果使用 Docker)
where docker >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Starting Supabase with Docker...
    docker run -d ^
        --name supabase-db ^
        -p 54322:5432 ^
        -e POSTGRES_PASSWORD=postgres ^
        -e POSTGRES_DB=postgres ^
        postgres:15 2>nul || echo Supabase DB container already running
) else (
    echo Docker not found, skipping Supabase setup
)

REM 启动各个服务
echo Starting services...

REM 启动后端服务器
echo Starting backend server...
start /B cmd /c "cd apps\web\server && bun run dev > ..\..\logs\server.log 2>&1"

REM 启动预加载服务
echo Starting preload service...
start /B cmd /c "cd apps\web\preload && bun run server/index.ts > ..\..\logs\preload.log 2>&1"

REM 启动模板服务
echo Starting template service...
start /B cmd /c "cd apps\web\template && bun run dev > ..\..\logs\template.log 2>&1"

REM 等待服务启动
timeout /t 5 /nobreak >nul

REM 创建停止脚本
(
    echo @echo off
    echo echo Stopping all services...
    echo taskkill /F /IM bun.exe 2^>nul
    echo docker stop supabase-db 2^>nul
    echo echo All services stopped
) > stop-all-services.bat

REM 启动前端客户端
echo Starting frontend client...
echo The frontend will be available at: http://localhost:3000
echo.
echo Press Ctrl+C to stop all services
echo.

cd apps\web\client
call bun run dev