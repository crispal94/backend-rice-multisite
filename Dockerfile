FROM node:20-alpine

WORKDIR /app

RUN apk add --no-cache python3 make g++
RUN npm install -g pnpm

COPY package.json pnpm-lock.yaml* package-lock.json* ./

RUN pnpm install --no-frozen-lockfile --shamefully-hoist

COPY . .

# >>>>> ¡ESTA ES LA LÍNEA MÁGICA! <<<<<
# Borramos la carpeta .medusa que viene de tu PC para evitar conflictos de Windows vs Linux
RUN rm -rf .medusa
# >>>>> ------------------------- <<<<<

ENV NODE_ENV=production

# Ahora construimos de cero en limpio
RUN npx medusa build

CMD ["pnpm", "start"]