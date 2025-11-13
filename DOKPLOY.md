
# Guía de Despliegue en Dokploy

Dokploy es una plataforma de despliegue simplificada. Aquí te muestro cómo configurar tu Portfolio.

## Requisitos Previos

- Cuenta en [Dokploy](https://dokploy.com)
- Tu repositorio en GitHub conectado a Dokploy
- Dokploy instalado en tu servidor (o usando el servicio en la nube)

## Pasos para Desplegar

### 1. Opción A: Usando la Interfaz Web de Dokploy

1. Accede a tu panel de Dokploy
2. Crea un nuevo Proyecto
3. Selecciona **"Docker"** como tipo de despliegue
4. Conecta tu repositorio GitHub (EricMartinezLabrin/Portfolio)
5. Elige la rama **main**
6. En configuración:
   - **Dockerfile**: `Dockerfile`
   - **Puerto Expuesto**: `4321`
   - **Variables de Entorno**:
     ```
     NODE_ENV=production
     ```
7. Configura el dominio (ej: portfolio.tudominio.com)
8. Haz clic en **Deploy**

### 2. Opción B: Usando Docker Compose (en tu servidor)

Si tienes Dokploy instalado localmente o en un servidor:

```bash
# Clona el repositorio
git clone https://github.com/EricMartinezLabrin/Portfolio.git
cd Portfolio

# Desplieg con docker-compose
docker-compose -f docker-compose.yml up -d --build
```

### 3. Opción C: Usando Dokploy CLI (si está disponible)

```bash
# Instala Dokploy CLI
npm install -g dokploy-cli

# Autentica
dokploy login

# Desplieg
dokploy deploy --config dokploy.json
```

## Configuración Recomendada en Dokploy

### Build Settings
- **Build Command**: `pnpm install --frozen-lockfile && pnpm build`
- **Start Command**: `pnpm preview --host 0.0.0.0 --port 4321`

### Environment Variables
```
NODE_ENV=production
PORT=4321
```

### Health Check
- **Enabled**: ✓
- **Path**: `/`
- **Interval**: 30s
- **Timeout**: 10s
- **Retries**: 3

### Resources (Recomendado)
- **CPU Limit**: 1 core
- **Memory Limit**: 512Mi

### Networking
- **Port**: 4321
- **Protocol**: HTTP/HTTPS (recomendado HTTPS con Let's Encrypt)

## Después del Despliegue

### Ver Logs
En el panel de Dokploy, ve a **Logs** para monitorear la aplicación.

### Configurar SSL/HTTPS
Dokploy puede automatizar esto con Let's Encrypt. Habilítalo en los settings del proyecto.

### Actualizar Despliegue
Simplemente pushea cambios a `main` branch, Dokploy detectará los cambios y redeployará automáticamente (si tienes CI/CD habilitado).

## Alternativas para Dokploy

Si prefieres otras plataformas:

- **Vercel**: Específicamente optimizado para Astro
- **Netlify**: También excelente para sitios estáticos
- **Railway**: Simple y flexible
- **Render**: Muy similar a Dokploy

## Troubleshooting

### Puerto no está accesible
- Verifica que el puerto 4321 no esté bloqueado por firewall
- Comprueba en Dokploy que el puerto esté correctamente mapeado

### Build falla
- Revisa los logs en Dokploy
- Asegúrate de que `pnpm-lock.yaml` está en el repositorio
- Verifica que Node 20 es compatible con todas las dependencias

### La app no inicia
- Revisa que el comando `pnpm preview` sea correcto
- Comprueba la variable `NODE_ENV=production`
- Verifica los logs de error
