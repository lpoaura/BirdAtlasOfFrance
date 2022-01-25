## Build
FROM node:14-bullseye as builder
WORKDIR /app
COPY  ["package.json", "package-lock.json","./"]
RUN npm install
COPY . ./
RUN npm run build
RUN ls /app/.nuxt


## Prod
FROM node:alpine
RUN apk update && apk upgrade && \
  apk add --no-cache git
WORKDIR /app
COPY  ["package.json", "package-lock.json","./"]
# ENV NODE_ENV=production
RUN npm install --production
# RUN apt-get clean autoclean &&\
#   apt-get autoremove --yes && \
#   rm -rf /var/lib/{apt,dpkg,cache,log}/
COPY nuxt.config.js ./
COPY --from=builder ["/app/.nuxt","/app/static","/app/content","./"]
RUN echo ">>> ls /app" && ls /app && echo ">>> end ls /app"
# COPY --from=builder /app/static ./static/
# COPY --from=builder /app/content ./content/
EXPOSE 3000
ENV NUXT_HOST=0.0.0.0
ENTRYPOINT [ "npm", "run" ]
CMD [ "start" ]
