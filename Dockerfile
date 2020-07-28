FROM ubuntu:18.04

RUN apt-get update \
    && apt-get install -y nginx-extras \
    && apt-get install -y git \
    && apt-get install apache2-utils -y \
    && rm -rf /var/lib/apt/lists/*

ADD keeweb-webdav-nginx-docker.sh /keeweb-webdav-nginx-docker.sh
ADD parseProperties.sh /parseProperties.sh
ADD keeweb.properties /keeweb.properties

RUN /keeweb-webdav-nginx-docker.sh

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]