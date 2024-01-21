# OBS! remove use of --legacy-peer-deps and
# use --production after solving the dependency issues
FROM node:18-alpine AS build

WORKDIR /app
COPY package*.json .
RUN rm -rf node_modules
RUN rm -rf build
#RUN npm install
RUN npm install --legacy-peer-deps
COPY . .
RUN npm run build

FROM node:18-alpine AS run

WORKDIR /app
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/build ./build
#RUN npm install --production
RUN npm install --legacy-peer-deps
ENTRYPOINT [ "node", "build" ]