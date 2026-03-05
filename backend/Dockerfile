# ------------ BUILD STAGE ------------
FROM node:20-alpine AS builder

WORKDIR /app

# Copy only dependency files first
COPY package*.json ./

# Install ALL deps (including dev) for build step
RUN npm ci

# Copy source code
COPY . .

# If you are using TypeScript, uncomment:
# RUN npm run build


# ------------ PRODUCTION STAGE ------------
FROM node:20-alpine

WORKDIR /app

# Copy only package files
COPY package*.json ./

# Install ONLY production dependencies
RUN npm ci --omit=dev

# Copy built app from builder
COPY --from=builder /app ./

EXPOSE 3000

CMD ["npm", "start"]
