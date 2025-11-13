# --- ETAPA 1: BUILD ---
FROM node:20-alpine AS builder
WORKDIR /app

# Instalar pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Copiar dependencias
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile

# Copiar código y construir
COPY . .
# Astro construye en /dist por defecto
RUN pnpm build

# --- ETAPA 2: SERVIDOR NGINX ---
FROM nginx:stable-alpine AS production

# 1. Borramos la configuración por defecto para evitar conflictos
RUN rm -rf /etc/nginx/conf.d/*

# 2. IMPORTANTE: Sobrescribimos la configuración MAESTRA porque tu archivo es completo
COPY nginx.conf /etc/nginx/nginx.conf

# 3. Copiamos los archivos estáticos generados por Astro
COPY --from=builder /app/dist/ /usr/share/nginx/html/

# Exponer puerto 80 (Coincide con tu nginx.conf)
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]