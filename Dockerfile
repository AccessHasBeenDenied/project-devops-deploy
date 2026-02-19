# NPM Build Stage
FROM node:24-alpine AS frontend
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# Java Build Stage

FROM gradle:9.2.1-jdk21 AS backend
WORKDIR /app/backend
COPY gradle gradle
COPY public public
COPY src src
COPY build.gradle.kts build.gradle.kts
COPY gradlew gradlew
COPY settings.gradle.kts settings.gradle.kts
COPY versions.properties versions.properties
RUN ./gradlew dependencies
RUN rm -rf src/main/resources/static \
    && mkdir -p src/main/resources/static
COPY --from=frontend /app/frontend/dist src/main/resources/static
RUN ./gradlew build

# Package Stage

FROM eclipse-temurin:21-jre-alpine
ARG APP_VERSION=0.0.1-SNAPSHOT
ENV JAR_NAME=project-devops-deploy-${APP_VERSION}.jar
WORKDIR /app/backend
COPY --from=backend /app/backend/build/libs/$JAR_NAME app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]