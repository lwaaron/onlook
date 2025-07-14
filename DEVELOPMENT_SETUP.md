# Onlook 项目开发环境设置指南

## 快速开始

### Linux/macOS 用户
```bash
# 赋予脚本执行权限
chmod +x start-all-services.sh

# 启动所有服务
./start-all-services.sh

# 停止所有服务
./stop-all-services.sh
```

### Windows 用户
```batch
# 双击运行或在命令行执行
start-all-services.bat

# 停止服务
stop-all-services.bat
```

### 测试模式（仅启动前端）
```bash
./test-start.sh
```

## 项目架构

```
onlook/
├── apps/
│   ├── web/
│   │   ├── client/     # Next.js 前端应用 (端口 3000)
│   │   ├── server/     # 后端服务器 (端口 8081-8082)
│   │   ├── preload/    # 预加载服务 (端口 8083)
│   │   └── template/   # 模板服务 (端口 8084)
│   └── backend/        # Supabase 后端配置
├── packages/           # 共享包
│   ├── db/            # 数据库模型
│   ├── ui/            # UI 组件库
│   ├── ai/            # AI 集成
│   └── ...            # 其他共享包
└── tooling/           # 开发工具

```

## Mock 认证说明

为了方便二次开发，已经配置了 Mock 认证系统：

- **Mock 用户信息**：
  - Email: `developer@onlook.dev`
  - User ID: `mock-user-123`
  - 名称: `Onlook Developer`

- **启用条件**：
  - 在 localhost 环境下自动启用
  - 设置 `SKIP_ENV_VALIDATION=true`

- **相关文件**：
  - `apps/web/client/src/utils/supabase/mock-auth.ts` - Mock 认证实现
  - `apps/web/client/src/utils/supabase/server.ts` - 服务器端集成

## 环境变量配置

默认的 `.env.local` 文件包含以下配置：

```env
# 基础配置
NODE_ENV=development
NEXT_PUBLIC_SITE_URL=http://localhost:3000

# Supabase (Mock)
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=mock-key
SUPABASE_DATABASE_URL=postgresql://postgres:postgres@localhost:54322/postgres

# AI 服务（需要真实密钥才能使用 AI 功能）
ANTHROPIC_API_KEY=mock-anthropic-key
GOOGLE_AI_STUDIO_API_KEY=mock-google-key
OPENAI_API_KEY=mock-openai-key

# 其他服务
CSB_API_KEY=mock-csb-api-key
SKIP_ENV_VALIDATION=true
```

## 二次开发指南

### 1. 添加新功能

在 `apps/web/client/src` 目录下添加新的页面或组件：

```typescript
// 新页面示例：app/my-feature/page.tsx
export default function MyFeaturePage() {
  return <div>My New Feature</div>
}
```

### 2. 修改认证逻辑

如果需要自定义认证逻辑，修改 `mock-auth.ts`：

```typescript
// 自定义用户数据
export const mockUser = {
  id: 'your-custom-id',
  email: 'your-email@example.com',
  // ... 其他字段
}
```

### 3. 使用真实的后端服务

1. 获取真实的 Supabase 凭据
2. 更新 `.env.local` 中的相关配置
3. 删除或注释掉 `SKIP_ENV_VALIDATION=true`

### 4. 添加新的 API 路由

在 `apps/web/client/src/server/api/routers` 目录下创建新的路由：

```typescript
// 新路由示例
import { createTRPCRouter, protectedProcedure } from "../trpc";

export const myRouter = createTRPCRouter({
  myEndpoint: protectedProcedure
    .query(async ({ ctx }) => {
      // 你的逻辑
      return { success: true };
    }),
});
```

## 常见问题

### Q: 如何切换到生产模式？
A: 设置 `NODE_ENV=production` 并提供真实的 API 密钥。

### Q: 如何禁用 Mock 认证？
A: 删除 `.env.local` 中的 `SKIP_ENV_VALIDATION=true`。

### Q: 如何添加新的依赖？
A: 在相应的目录运行 `bun add <package-name>`。

### Q: 日志文件在哪里？
A: 所有服务日志保存在 `logs/` 目录下。

## 服务端口

- Frontend Client: http://localhost:3000
- Backend Server: http://localhost:8081
- WebSocket Server: http://localhost:8082
- Preload Service: http://localhost:8083
- Template Service: http://localhost:8084
- Supabase DB: postgresql://localhost:54322

## 调试技巧

1. **查看服务日志**：
   ```bash
   tail -f logs/server.log
   tail -f logs/preload.log
   tail -f logs/template.log
   ```

2. **检查服务状态**：
   ```bash
   # Linux/macOS
   ps aux | grep bun
   
   # Windows
   tasklist | findstr bun
   ```

3. **重启单个服务**：
   停止特定服务后，在相应目录运行 `bun run dev`

## 联系和支持

- 项目文档：https://docs.onlook.com
- GitHub Issues：https://github.com/onlook-dev/onlook/issues
- Discord：https://discord.gg/hERDfFZCsH