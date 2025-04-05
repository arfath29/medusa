<<<<<<< HEAD
# Use Node 20 as required by Medusa
FROM node:20

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy entire app
COPY . .

# Expose port
EXPOSE 9000

# Start the server
CMD ["npm", "run", "start"]
=======
FROM medusa/medusa:latest
WORKDIR /app
COPY . .
RUN npm install
CMD ["medusa", "start"]
>>>>>>> ad11237cfc4c4d1c657ed4624142cd7f8ac2f4e5
