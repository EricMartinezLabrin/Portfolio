# Etapa 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar archivos de dependencias
COPY package.json pnpm-lock.yaml ./

# Instalar pnpm y dependencias
RUN npm install -g pnpm && \
    pnpm install --frozen-lockfile

# Copiar el resto del código
COPY . .

# Build del proyecto
RUN pnpm build

# Etapa 2: Runtime (producción)
FROM node:20-alpine

WORKDIR /app

# Instalar pnpm
RUN npm install -g pnpm

# Copiar solo los archivos necesarios desde el builder
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod --frozen-lockfile

# Copiar la carpeta dist desde el builder
COPY --from=builder /app/dist ./dist

# Exponer puerto
EXPOSE 4321

# Comando para servir
CMD ["pnpm", "preview", "--host", "0.0.0.0", "--port", "4321"]
