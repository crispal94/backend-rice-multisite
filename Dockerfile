FROM node:20-alpine

WORKDIR /app

RUN apk add --no-cache python3 make g++
RUN npm install -g pnpm

COPY package.json pnpm-lock.yaml* package-lock.json* ./

# --- CAMBIO IMPORTANTE AQUÍ ---
# Agregamos --shamefully-hoist para que encuentre los @types y el dashboard
RUN pnpm install --no-frozen-lockfile --shamefully-hoist
# ------------------------------

COPY . .

ENV NODE_ENV=production

# Usamos npx para construir (más seguro que pnpm run build directo en algunos casos)
RUN npx medusa build

CMD ["pnpm", "start"]