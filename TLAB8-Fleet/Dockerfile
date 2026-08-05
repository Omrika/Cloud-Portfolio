# SABOTAGE: Bloated base image running as root by default
FROM node:alpine

WORKDIR /usr/src/app

USER node 

EXPOSE 8080
CMD [ "node" ]

COPY . .
