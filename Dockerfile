FROM  node:18-bullseye-slim as builder
WORKDIR /usr/src/app/doc
COPY package*.json ./
RUN npm install --force
COPY ./ .
RUN npm run build
RUN ls /

usr/src/app/doc/build # afficher le contenu du dossier build
RUN find /usr/src/app/doc/build -name "*.map" -type f -delete

# production environment
FROM nginx:stable-bullseye
RUN rm -rf /etc/nginx/conf.d
RUN mkdir -p /etc/nginx/conf.d
COPY ./default.conf /etc/nginx/conf.d/

RUN sed -i "s/API_PORT/80/g" /etc/nginx/conf.d/default.conf
COPY --from=builder /usr/src/app/doc/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]