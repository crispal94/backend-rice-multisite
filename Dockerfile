FROM node:20-alpine AS base

WORKDIR /app
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* bun.lockb* ./

# Instalamos dependencias
RUN npm install -g bun
RUN bun install

COPY . .

# Construimos el proyecto (Medusa v2 lo requiere)
RUN bun run build

# Comando de inicio
CMD ["bun", "start"]