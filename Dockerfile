# Étape 1 : Construction de l'application
FROM node:18-alpine as builder
WORKDIR /usr/src/app/doc
COPY package*.json ./

# Installer Git
RUN apk update && apk add git

RUN npm install --force
COPY ./ .
RUN yarn build
RUN ls /usr/src/app/doc/build # afficher le contenu du dossier build
RUN find /usr/src/app/doc/build -name "*.map" -type f -delete

# Étape 2 : Configuration de l'environnement de production
FROM nginx:stable-bullseye

RUN rm -rf /etc/nginx/conf.d
RUN mkdir -p /etc/nginx/conf.d
COPY ./default.conf /etc/nginx/conf.d/

RUN sed -i "s/API_PORT/80/g" /etc/nginx/conf.d/default.conf
COPY --from=builder /usr/src/app/doc/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
