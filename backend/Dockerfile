FROM node:lts-alpine
RUN apk add --update curl && \
    rm -rf /var/cache/apk/*
ENV NODE_ENV=production
WORKDIR /usr/src/app
COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
RUN npm install --production --silent && mv node_modules ../
COPY . .
EXPOSE 3500
RUN chown -R node /usr/src/app
USER node
CMD ["npm", "start"]
