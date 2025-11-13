# Portfolio - Deployment con Traefik

## Configuración con Docker y Traefik

Este proyecto incluye todo lo necesario para ejecutar el portfolio con Traefik como reverse proxy.

### Archivos incluidos

- `Dockerfile` - Imagen de producción multi-stage (Node + pnpm → nginx)
- `docker-compose.yml` - Orquestación con Traefik
- `nginx.conf` - Configuración de nginx optimizada para Traefik
- `.dockerignore` - Exclusión de archivos innecesarios

### Inicio rápido (desarrollo local)

```bash
# Construir y ejecutar con docker-compose
docker-compose up -d

# Ver logs
docker-compose logs -f portfolio

# Detener servicios
docker-compose down
```

El sitio estará disponible en:
- **Portfolio**: http://localhost
- **Dashboard de Traefik**: http://localhost:8080

### Configuración para producción

#### 1. Ajustar el dominio en `docker-compose.yml`

Edita las etiquetas de Traefik en el servicio `portfolio`:

```yaml
labels:
  # Cambiar localhost por tu dominio
  - "traefik.http.routers.portfolio.rule=Host(`tu-dominio.com`)"
  - "traefik.http.routers.portfolio-secure.rule=Host(`tu-dominio.com`)"
```

#### 2. Habilitar HTTPS con Let's Encrypt

Descomenta las siguientes líneas en `docker-compose.yml`:

**En el servicio `traefik`:**
```yaml
command:
  - "--certificatesresolvers.letsencrypt.acme.httpchallenge=true"
  - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
  - "--certificatesresolvers.letsencrypt.acme.email=tu-email@ejemplo.com"
  - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
volumes:
  - ./letsencrypt:/letsencrypt
```

**En el servicio `portfolio`:**
```yaml
labels:
  - "traefik.http.routers.portfolio-secure.entrypoints=websecure"
  - "traefik.http.routers.portfolio-secure.tls=true"
  - "traefik.http.routers.portfolio-secure.tls.certresolver=letsencrypt"
  - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
  - "traefik.http.routers.portfolio.middlewares=redirect-to-https"
```

#### 3. Crear directorio para certificados SSL

```bash
mkdir -p letsencrypt
chmod 600 letsencrypt
```

#### 4. Deshabilitar dashboard de Traefik en producción

Cambia en el servicio `traefik`:
```yaml
command:
  - "--api.insecure=false"  # Cambiar a false
```

Y elimina el puerto 8080 de `ports`:
```yaml
ports:
  - "80:80"
  - "443:443"
  # - "8080:8080"  # Comentar o eliminar
```

### Comandos útiles

```bash
# Reconstruir imagen después de cambios
docker-compose up -d --build

# Ver logs en tiempo real
docker-compose logs -f

# Reiniciar solo el servicio portfolio
docker-compose restart portfolio

# Ver estado de contenedores
docker-compose ps

# Ejecutar bash dentro del contenedor
docker-compose exec portfolio sh

# Limpiar todo (contenedores, volúmenes, imágenes)
docker-compose down -v
docker system prune -a
```

### Características de la configuración

#### Nginx
- ✅ Compresión gzip habilitada
- ✅ Cache de assets estáticos (1 año)
- ✅ Security headers (X-Frame-Options, X-Content-Type-Options, etc.)
- ✅ Health check endpoint en `/health`
- ✅ Soporte para X-Forwarded headers (Traefik)
- ✅ SPA fallback (todas las rutas → index.html)

#### Docker
- ✅ Multi-stage build (imagen optimizada)
- ✅ Health check integrado
- ✅ Cache de dependencias de pnpm
- ✅ Usuario no-root en nginx

#### Traefik
- ✅ Auto-discovery de servicios Docker
- ✅ Let's Encrypt automático (cuando se configura)
- ✅ Redirección HTTP → HTTPS
- ✅ Dashboard de monitoreo

### Troubleshooting

**El sitio no carga:**
```bash
# Verificar que los contenedores estén corriendo
docker-compose ps

# Ver logs de errores
docker-compose logs portfolio
docker-compose logs traefik
```

**Error 404 en rutas:**
- Verifica que `nginx.conf` tenga `try_files $uri $uri/ /index.html;`

**Certificados SSL no se generan:**
- Asegúrate de que el puerto 80 esté accesible desde internet
- Verifica que el dominio apunte a tu servidor
- Revisa los logs: `docker-compose logs traefik`

**La imagen es muy grande:**
```bash
# Ver tamaño de la imagen
docker images | grep portfolio

# Si es > 100MB, verifica que .dockerignore esté correcto
```

### Variables de entorno (opcional)

Si necesitas variables de entorno en el build de Astro, agrégalas en `docker-compose.yml`:

```yaml
services:
  portfolio:
    build:
      context: .
      args:
        - PUBLIC_API_URL=https://api.ejemplo.com
```

Y en el `Dockerfile` (stage builder):
```dockerfile
ARG PUBLIC_API_URL
ENV PUBLIC_API_URL=$PUBLIC_API_URL
```

### Recursos adicionales

- [Documentación de Traefik](https://doc.traefik.io/traefik/)
- [Documentación de Astro](https://docs.astro.build/)
- [Nginx en Docker](https://hub.docker.com/_/nginx)
