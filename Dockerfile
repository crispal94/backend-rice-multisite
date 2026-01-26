FROM node:20-alpine

WORKDIR /app

# 1. Instalamos pnpm globalmente y herramientas de compilación básicas
# (python y make a veces son necesarios para dependencias nativas de Medusa)
RUN apk add --no-cache python3 make g++
RUN npm install -g pnpm

# 2. Copiamos los archivos de dependencias
# Nota: Copiamos package-lock.json también por si acaso no generaste el de pnpm aún
COPY package.json pnpm-lock.yaml* package-lock.json* ./

# 3. Instalamos dependencias
# Usamos --no-frozen-lockfile para que no falle si no tienes el pnpm-lock.yaml todavía
RUN pnpm install --no-frozen-lockfile

# 4. Copiamos el resto del código
COPY . .

# 5. CONFIGURACIÓN CRÍTICA DE PRODUCCIÓN
ENV NODE_ENV=production

# 6. Construimos el proyecto (Admin + Backend)
# Al usar pnpm run build, se ejecuta "medusa build" en un entorno limpio
RUN pnpm run build

# 7. Comando de arranque
# Ejecutará tu script "start" del package.json (el que tiene las migraciones)
CMD ["pnpm", "start"]