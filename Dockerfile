# ======================
# Stage 1: Base with pnpm
# ======================
FROM node:20-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable && corepack prepare pnpm@latest --activate

# ======================
# Stage 2: Build frontend & MCP
# ======================
FROM base AS build
WORKDIR /app
COPY . .
# 安装依赖并构建（使用 --frozen-lockfile 确保一致性）
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm run build          # 构建 Web 前端 (dist)
RUN pnpm mcp:build          # 构建 MCP 服务 (dist)

# ======================
# Stage 3: Final runtime image
# ======================
FROM nginx:stable-alpine

# 安装必要工具（全部来自 Alpine 本地包，无需联网）
RUN apk add --no-cache \
    apache2-utils \          # htpasswd
    dos2unix \               # 处理 Windows 行尾符
    supervisor \             # 进程管理
    curl \                   # healthcheck 用
    nodejs                   # 运行 MCP 服务（Alpine 自带 npm，无需额外装 pnpm）

# 复制 Nginx 配置
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# 复制构建产物（只复制必要的 dist 和配置）
COPY --from=build /app/packages/web/dist /usr/share/nginx/html

# MCP 服务：只复制 dist + package.json + 启动脚本
COPY --from=build /app/packages/mcp-server/dist /app/mcp-server/dist
COPY --from=build /app/packages/mcp-server/package.json /app/mcp-server/
COPY --from=build /app/packages/mcp-server/preload-env.js /app/mcp-server/
COPY --from=build /app/packages/mcp-server/preload-env.cjs /app/mcp-server/

# Node Proxy（假设已构建到 /app/node-proxy）
COPY --from=build /app/node-proxy /app/node-proxy

# 设置工作目录
WORKDIR /app/mcp-server

# 复制启动脚本
COPY docker/generate-config.sh /docker-entrypoint.d/40-generate-config.sh
COPY docker/generate-auth.sh /docker-entrypoint.d/30-generate-auth.sh
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/start-services.sh /start-services.sh

# 修复权限和行尾符
RUN chmod +x /docker-entrypoint.d/*.sh /start-services.sh \
 && dos2unix /docker-entrypoint.d/*.sh /start-services.sh

EXPOSE 80
CMD ["sh", "/start-services.sh"]