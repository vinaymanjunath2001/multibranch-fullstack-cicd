FROM node:20-alpine

WORKDIR /app

# Copy only dependency files first (better caching)
COPY package*.json ./

# Install only production dependencies
RUN npm ci --omit=dev

# Copy app source
COPY . .

# Build React app
RUN npm run build

# Install lightweight static server globally once
RUN npm install -g serve

EXPOSE 3001

CMD ["serve", "-s", "build", "-l", "3001"]
