## Build
FROM node:lts-bullseye as builder
ENV NODE_OPTIONS=--openssl-legacy-provider
WORKDIR /app
COPY  ["package.json", "package-lock.json","./"]
RUN npm install
COPY . ./
RUN npm run build


## Prod
FROM node:lts-bullseye
ENV NODE_OPTIONS=--openssl-legacy-provider
RUN apt update && apt upgrade -y && apt install -y git
WORKDIR /app
COPY  ["package.json", "package-lock.json","./"]
RUN npm install --production
COPY nuxt.config.js ./
COPY --from=builder /app/.nuxt ./.nuxt/
COPY --from=builder /app/static ./static/
COPY --from=builder /app/content ./content/
EXPOSE 3000
ENV NUXT_HOST=0.0.0.0
ENTRYPOINT [ "npm", "run" ]
CMD [ "start" ]
