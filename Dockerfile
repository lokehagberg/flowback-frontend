# TODO: Have a production setting (either in Dockerfile or in docker-compose, set in .env)
# https://medium.com/@balazs.csaba.diy/optimized-dockerfile-for-sveltekit-applications-from-experience-and-best-practices-99603d8d1303
ARG NODE_IMAGE=node:24-alpine3.22
ARG PORT="3000"

FROM ${NODE_IMAGE} AS sk-build
WORKDIR /app

# Sets the timezone
ARG TZ=Europe/Stockholm

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build && \
  find build -name "*.map" -delete


FROM ${NODE_IMAGE} as runner

WORKDIR /app

# Copy only necessary config and manifest files from local context
# No need to create node user and node groups, because these are exist by default
COPY --chown=node:node .npmrc package.json package-lock.json .

RUN npm ci --omit=dev --ignore-scripts

# Copy build output from build stage
COPY --from=sk-build --chown=node:node /app/build ./build
# Clean up npm cache to reduce image size
# npm cache clean --force && \
# Remove unnecessary files and folders from node_modules such as docs, tests, maps, git metadata
# find node_modules \( \
# -type d -empty \
# -o -iname "license*" \
# -o -name "*.md" \
# -o -name "*.txt" \
# -o -name "*.map" \
# -o -name ".git*" \
# -o -name "*.yml" \
# -o -name "*.yaml" \
# -o -name "*.json" -path "*/test/*" \
# -o -name "*.json" -path "*/tests/*" \
# -o -name "test" -type d \
# -o -name "tests" -type d \
# -o -name "__tests__" -type d \
# -o -name "coverage" -type d \
# -o -name ".nyc_output" -type d \
# \) -delete && \
# # Remove leftover tmp and cache files
# rm -rf /tmp/* /var/cache/apk/* /root/.npm && \
# # Remove globally installed npm to save space and remove vulnerability
# npm r -g npm

# Switch to non-root user
USER node

# Set environment variable
ENV NODE_ENV=production

EXPOSE ${PORT}

CMD ["node", "build"]
