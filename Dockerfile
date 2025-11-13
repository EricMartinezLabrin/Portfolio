# Dockerfile de producción multi-stage para un sitio Astro (static) usando pnpm
# Etapa de build: instalar dependencias y construir
FROM node:20-alpine AS builder

WORKDIR /app

# Dependencias del sistema necesarias (si alguna dependencia nativa lo requiere)
RUN apk add --no-cache libc6-compat

# Usar corepack para activar pnpm (incluido en Node >=16.14+ / 18+). Ajustar versión si se desea.
RUN corepack enable && corepack prepare pnpm@latest --activate

# Copiar archivos de lock y package para aprovechar cache de dependencias
COPY package.json pnpm-lock.yaml* ./

# Instalar dependencias (incluye dev deps, necesarias para el build porque `astro check` puede necesitarlas)
RUN pnpm install --frozen-lockfile

# Copiar el resto del proyecto y ejecutar el build
COPY . .

# Construcción de producción
ENV NODE_ENV=production
RUN pnpm build

# Etapa final: servir contenido estático con nginx
FROM nginx:stable-alpine AS production

# Eliminamos el default index.html y la configuración por defecto
RUN rm -rf /usr/share/nginx/html/* /etc/nginx/conf.d/default.conf

# Copiar la salida de Astro
COPY --from=builder /app/dist/ /usr/share/nginx/html/

# Copiar configuración personalizada de nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Exponer puerto 80 por defecto
EXPOSE 80

# Ejecutar nginx en primer plano
CMD ["nginx", "-g", "daemon off;"]
