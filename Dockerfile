FROM node:20-alpine

WORKDIR /app

RUN apk add --no-cache python3 make g++
RUN npm install -g pnpm

COPY package.json pnpm-lock.yaml* package-lock.json* ./

RUN pnpm install --no-frozen-lockfile --shamefully-hoist

COPY . .

RUN rm -rf .medusa

ENV NODE_ENV=production

# 1) Build de producción
RUN npx medusa build

# 2) Instalar dependencias dentro del build generado
WORKDIR /app/.medusa/server
RUN pnpm install --prod --ignore-scripts

# 3) Comando de arranque: desde .medusa/server
# Usamos el formato Shell (sin corchetes []) para permitir concatenar comandos
CMD /bin/sh -c "pnpm medusa exec ./src/scripts/seed.js && pnpm medusa start -H 0.0.0.0"
