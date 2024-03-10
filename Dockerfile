FROM node:18-alpine AS sk-build
WORKDIR /usr/src/app

# This just sets the timezone
ARG TZ=Europe/Stockholm

COPY . /usr/src/app
RUN apk --no-cache add curl tzdata
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN npm install
RUN npm run build

FROM node:18-alpine
WORKDIR /usr/src/app

# This just sets the timezone
ARG TZ=Europe/Stockholm
RUN apk --no-cache add curl tzdata
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY --from=sk-build /usr/src/app/package.json /usr/src/app/package.json
COPY --from=sk-build /usr/src/app/package-lock.json /usr/src/app/package-lock.json

# Should use "--only=production" but generates errors
# best guess is that there are some outdated packaged,
# but we don't know
#RUN npm i --only=production
RUN npm i

COPY --from=sk-build /usr/src/app/build /usr/src/app/build

EXPOSE 3000
CMD ["node", "build/index.js"]