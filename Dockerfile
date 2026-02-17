# Java Build Stage

FROM gradle:9.2.1-jdk21 AS backend
WORKDIR /app/backend
COPY . . 
RUN gradle build

# NPM Build Stage

FROM node:20-alpine AS frontend
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# Package Stage

FROM eclipse-temurin:21
RUN apt-get update \
    && apt-get install -y nginx-light \
    && rm -rf /var/lib/apt/lists/*
ENV JAR_NAME=project-devops-deploy-0.0.1-SNAPSHOT.jar
WORKDIR /app/backend
COPY --from=frontend /app/frontend/dist /app/frontend
COPY --from=backend /app/backend/build/libs/$JAR_NAME app.jar
COPY configs/nginx.conf /etc/nginx/nginx.conf
COPY --chmod=550 configs/entrypoint.sh .
EXPOSE 80
ENTRYPOINT ["/app/backend/entrypoint.sh"]