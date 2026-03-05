# Stage 1: Build
FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./
COPY prisma/ ./prisma/
RUN npm ci && npx prisma generate

COPY tsconfig.json ./
COPY src/ ./src/
RUN npm run build


# Stage 2: Production
FROM node:22-alpine AS production

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Copy compiled app and Prisma-generated query engine from builder
COPY --from=builder --chown=node:node /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder --chown=node:node /app/dist ./dist

# Copy Prisma CLI, dotenv (devDeps, stripped above), and migrations so the
# entrypoint can run `prisma migrate deploy` before starting the app
COPY --from=builder /app/node_modules/prisma ./node_modules/prisma
COPY --from=builder /app/node_modules/.bin/prisma ./node_modules/.bin/prisma
COPY --from=builder /app/node_modules/dotenv ./node_modules/dotenv
COPY prisma/schema.prisma ./prisma/
COPY prisma/migrations ./prisma/migrations
COPY prisma.config.ts ./

# Startup script: migrate then start
COPY entrypoint.sh ./
RUN chmod +x ./entrypoint.sh

USER node

EXPOSE 3001

CMD ["sh", "./entrypoint.sh"]
