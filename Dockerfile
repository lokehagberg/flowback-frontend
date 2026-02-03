FROM node:24-alpine3.21 AS sk-build
WORKDIR /app

# Sets the timezone
ARG TZ=Europe/Stockholm

COPY package*.json ./
RUN npm ci

COPY . .

ARG PORT="3000"
EXPOSE ${PORT}

# TODO: Have a production setting (either in Dockerfile or in docker-compose, set in .env)
