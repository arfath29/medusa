# Use Node 20
FROM node:20

# Set working directory
WORKDIR /app

# Copy package files and install deps
COPY package*.json ./
RUN npm install

# Copy the rest of the app
COPY . .

# Set environment variables (optional if you're using ECS secrets)
ENV NODE_ENV=production
ENV PORT=9000

# Expose port
EXPOSE 9000

# Start Medusa
CMD ["npm", "run", "start"]
