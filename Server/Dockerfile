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
EXPOSE 9090
CMD ["java", "-jar", "myapp.jar"]
