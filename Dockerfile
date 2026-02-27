# --- Stage 1: Build React Frontend ---
FROM node:16-alpine AS frontend-build
WORKDIR /app/client
COPY Client/package*.json ./
RUN npm install --legacy-peer-deps
COPY Client/ .
RUN npm run build

# --- Stage 2: Build Java Backend ---
FROM eclipse-temurin:17-jdk-alpine AS backend-build
WORKDIR /app/server
# Ensure Windows-style line endings (\r\n) don't break the build script
COPY Server/ .
RUN sed -i 's/\r$//' mvnw && chmod +x mvnw && ./mvnw clean package -DskipTests

# --- Stage 3: Final Monolithic Runtime ---
# Using Ubuntu because it's easier to manage multiple services (MySQL + Java)
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install Java 17, MySQL, and Node.js
RUN apt-get update && apt-get install -y \
    openjdk-17-jre-headless \
    mysql-server \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean

# 2. Copy built assets from previous stages
WORKDIR /app
COPY --from=backend-build /app/server/target/*.jar app.jar
COPY --from=frontend-build /app/client/build ./frontend-build

# 3. Application Configurations
ENV SPRING_DATASOURCE_URL=jdbc:mysql://localhost:3306/organica
ENV SPRING_DATASOURCE_USERNAME=root
ENV SPRING_DATASOURCE_PASSWORD=root
ENV SPRING_JPA_HIBERNATE_DDL_AUTO=update
ENV RAZORPAY_KEY_ID=dummy_key
ENV RAZORPAY_KEY_SECRET=dummy_secret

# 4. Create Entrypoint Script
# This starts MySQL, creates the database, and then runs our Java app and Frontend server
RUN echo '#!/bin/bash\n\
    service mysql start\n\
    sleep 5\n\
    # Initialize Database\n\
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS organica;"\n\
    mysql -u root -e "ALTER USER \"root\"@\"localhost\" IDENTIFIED WITH mysql_native_password BY \"root\"; FLUSH PRIVILEGES;"\n\
    # Start Spring Boot Backend in background\n\
    echo "Starting Backend..."\n\
    java -jar app.jar &\n\
    # Serve Frontend on port 3000\n\
    echo "Starting Frontend..."\n\
    npx serve -s ./frontend-build -l 3000' > /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh

# Port 3000 for Frontend, 8080 for Backend
EXPOSE 3000 8080

ENTRYPOINT ["/app/entrypoint.sh"]
