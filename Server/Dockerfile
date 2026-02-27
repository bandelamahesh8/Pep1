# Build stage
FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /app
COPY . .
# Convert CRLF to LF for mvnw script to ensure Windows compatibility 
# and make it executable, then build the application
RUN sed -i 's/\r$//' mvnw && chmod +x mvnw && ./mvnw clean package -DskipTests

# Run stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar myapp.jar

# Database & App configurations (moved from docker-compose)
ENV SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/organica
ENV SPRING_DATASOURCE_USERNAME=root
ENV SPRING_DATASOURCE_PASSWORD=root
ENV SPRING_JPA_HIBERNATE_DDL_AUTO=update
ENV RAZORPAY_KEY_ID=dummy_key
ENV RAZORPAY_KEY_SECRET=dummy_secret

# The app runs on 8080 inside the container
EXPOSE 8080
CMD ["java", "-jar", "myapp.jar"]
