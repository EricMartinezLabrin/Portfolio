#!/bin/bash

# Script de verificación pre-despliegue para Dokploy
# Este script verifica que todo esté configurado correctamente

echo "🔍 Verificando configuración para Dokploy..."
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contador de checks
PASSED=0
FAILED=0

# Función para verificar archivos
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 existe"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $1 no encontrado"
        ((FAILED++))
        return 1
    fi
}

# Función para verificar contenido
check_content() {
    if grep -q "$2" "$1" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $3"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $3"
        ((FAILED++))
        return 1
    fi
}

echo "📁 Verificando archivos esenciales..."
check_file "Dockerfile"
check_file "dokploy.yaml"
check_file "nginx.conf"
check_file "package.json"
check_file "pnpm-lock.yaml"
check_file "astro.config.mjs"

echo ""
echo "🔧 Verificando configuraciones..."
check_content "Dockerfile" "FROM node" "Dockerfile tiene etapa de build de Node"
check_content "Dockerfile" "FROM nginx" "Dockerfile tiene etapa de producción con Nginx"
check_content "Dockerfile" "EXPOSE 80" "Puerto 80 expuesto en Dockerfile"
check_content "dokploy.yaml" "port: 80" "Puerto 80 configurado en dokploy.yaml"
check_content "astro.config.mjs" "output.*static" "Astro configurado como sitio estático"
check_content "nginx.conf" "listen 80" "Nginx configurado para escuchar en puerto 80"
check_content "nginx.conf" "/health" "Health check endpoint configurado"

echo ""
echo "📦 Verificando dependencias..."
if command -v pnpm &> /dev/null; then
    echo -e "${GREEN}✓${NC} pnpm instalado"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠${NC} pnpm no instalado (opcional para verificación local)"
fi

if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓${NC} docker instalado"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠${NC} docker no instalado (opcional para verificación local)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Resumen:"
echo -e "${GREEN}Pasaron: $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Fallaron: $FAILED${NC}"
    echo ""
    echo -e "${RED}❌ Hay problemas que necesitan ser resueltos${NC}"
    exit 1
else
    echo ""
    echo -e "${GREEN}✅ Todo listo para desplegar en Dokploy!${NC}"
    echo ""
    echo "Próximos pasos:"
    echo "1. Commitea y pushea los cambios a tu repositorio"
    echo "2. En Dokploy, conecta tu repositorio"
    echo "3. Selecciona 'Docker' como tipo de aplicación"
    echo "4. Configura tu dominio"
    echo "5. ¡Despliega!"
    echo ""
    echo "Para verificar el build localmente (opcional):"
    echo "  docker build -t portfolio-test ."
    echo "  docker run -p 3000:80 portfolio-test"
    exit 0
fi
