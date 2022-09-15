#Dockerfile for building Nginx Docker Image

FROM alpine:latest

RUN apk update \
    && apk add nginx \
#for simple text start page
    && mv /etc/nginx/nginx.conf  /etc/nginx/nginx.conf.orig

#for html file start page
#    && mkdir /var/www/html \
#    && mv /etc/nginx/http.d/default.conf /etc/nginx/http.d/default.conf.orig

#for simple text start page
COPY ./nginx.conf /etc/nginx/nginx.conf

#for html file start page
#COPY ./index.html /var/www/html/index.html
#COPY ./default.conf /etc/nginx/http.d/default.conf

ENTRYPOINT ["nginx", "-g", "daemon off;"]
