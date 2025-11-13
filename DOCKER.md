# Guía de Dockerización - Portfolio

Este proyecto está configurado para ejecutarse en Docker. Se incluyen configuraciones tanto para producción como para desarrollo.

## Requisitos Previos

- Docker instalado en tu sistema
- Docker Compose (generalmente viene con Docker Desktop)

## Estructura de Archivos Docker

- `Dockerfile` - Imagen multi-stage para producción
- `Dockerfile.dev` - Imagen para desarrollo con hot reload
- `docker-compose.yml` - Composición para producción
- `docker-compose.dev.yml` - Composición para desarrollo
- `.dockerignore` - Archivos a excluir en build de producción

## Uso

### Producción

#### Construir la imagen:
```bash
docker build -t portfolio:latest .
```

#### Ejecutar con Docker Compose:
```bash
docker-compose up -d
```

La aplicación estará disponible en `http://localhost:3000`

#### Ejecutar manualmente:
```bash
docker run -p 3000:3000 portfolio:latest
```

### Desarrollo

#### Ejecutar con hot reload:
```bash
docker-compose -f docker-compose.dev.yml up
```

La aplicación estará disponible en `http://localhost:3000` con recarga automática.

#### Detener los contenedores:
```bash
docker-compose down
docker-compose -f docker-compose.dev.yml down
```

## Características

### Producción (Dockerfile)
- Build multi-stage para optimizar tamaño de imagen
- Usa Node.js 20-alpine (imagen ligera ~150MB)
- Instala solo dependencias de producción
- Expone puerto 3000
- Health check incluido
- Restart automático en caso de fallo

### Desarrollo (Dockerfile.dev)
- Instala todas las dependencias (incluidas dev)
- Hot reload con volumes
- Host accesible desde fuera del contenedor

## Comandos Útiles

### Ver logs
```bash
docker-compose logs -f
docker-compose -f docker-compose.dev.yml logs -f
```

### Ejecutar comandos dentro del contenedor
```bash
docker-compose exec portfolio pnpm build
docker-compose -f docker-compose.dev.yml exec portfolio-dev pnpm build
```

### Limpiar todo
```bash
docker-compose down -v
docker system prune -a
```

## Variables de Entorno

Puedes agregar un archivo `.env` en la raíz del proyecto para variables personalizadas:

```env
NODE_ENV=production
PORT=3000
```

## Solución de Problemas

### Puerto 3000 ya en uso
Cambiar el puerto en `docker-compose.yml`:
```yaml
ports:
  - "8000:3000"  # Escucha en 8000, mapea a 3000 del contenedor
```

### Permisos de archivos
En Linux, si hay problemas con permisos:
```bash
sudo chown -R $(id -u):$(id -g) .
```

### Limpiar caché
```bash
docker builder prune
docker-compose down -v
```
