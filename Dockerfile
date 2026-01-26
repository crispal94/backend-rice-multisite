FROM node:20-alpine AS base

WORKDIR /app

COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* bun.lockb* ./

# --- CORRECCIÓN CLAVE ---
# Le decimos a Docker que todo lo que haga de aquí en adelante es para Producción.
# Esto asegura que 'bun run build' genere el index.html donde debe estar.
ENV NODE_ENV=production
# ------------------------

# Instalamos dependencias (incluyendo devDependencies para poder construir)
RUN npm install -g bun
# Usamos --no-cache para asegurar una instalación limpia
RUN bun install

COPY . .

# Construimos el backend y el panel de admin
RUN bun run build

# El comando de inicio (usará el script 'start' que modificaste en el package.json)
CMD ["bun", "start"]