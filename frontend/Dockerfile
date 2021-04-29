## Build
FROM node:latest as builder
WORKDIR /app
COPY package.json ./
RUN yarn
COPY . ./
RUN yarn build

## Prod
FROM node:alpine
RUN apk update && apk upgrade && \
  apk add --no-cache git
WORKDIR /app
COPY package.json ./
# ENV NODE_ENV=production
RUN npm install --production
COPY nuxt.config.js ./
COPY --from=builder /app/.nuxt ./.nuxt/
COPY --from=builder /app/static ./static/
EXPOSE 3000
ENV NUXT_HOST=0.0.0.0
ENTRYPOINT [ "npm", "run" ]
CMD [ "start" ]
