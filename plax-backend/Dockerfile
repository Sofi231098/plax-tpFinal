# ---- Etapa de build ----
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copiamos solo el pom para cachear dependencias
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Ahora copiamos el resto del proyecto
COPY . .

# Compilamos y empaquetamos (deshabilitamos tests opcionalmente)
RUN mvn package -DskipTests

# ---- Imagen final (más liviana) ----
FROM eclipse-temurin:17-jdk
WORKDIR /app

# Copiamos solo el jar compilado desde la etapa build
COPY --from=build /app/target/*.jar app.jar
COPY .env .env

EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
