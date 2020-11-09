FROM centos:centos7

MAINTAINER WITO <dev@wito.technology>
LABEL Vendor="WITO"
LABEL Version=2.0

LABEL Build docker build --rm --tag centos/roombooked .

RUN yum -y install git wget curl vi

RUN curl -sL https://rpm.nodesource.com/setup_12.x | bash -
RUN curl -sL https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash -

RUN yum -y install --setopt=tsflags=nodocs epel-release && \ 
	yum -y install --setopt=tsflags=nodocs mariadb-server bind-utils pwgen psmisc hostname && \ 
	yum -y erase vim-minimal && \
	yum -y install nodejs nginx && \
	yum -y update && yum clean all

RUN mkdir -p /app/certs
RUN mkdir -p /app/frontend
RUN mkdir -p /app/backend

COPY certs /app/certs
COPY backend /app/backend
COPY frontend /app/frontend
COPY database.sql /

WORKDIR /app/backend
RUN npm install
RUN npm run build

WORKDIR /app/frontend
RUN npm install
RUN npm run build

COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/server.conf /etc/nginx/conf.d/

RUN mkdir -p /var/log/mariadb/
RUN mkdir -p /var/log/nginx

RUN chown -R nginx. /etc/nginx/
RUN chown -R nginx. /var/log/nginx/

WORKDIR /
# Fix permissions to allow for running on openshift
COPY fix-permissions.sh ./
RUN chmod +x ./fix-permissions.sh
RUN ./fix-permissions.sh /var/lib/mysql/   && \
	./fix-permissions.sh /var/log/mariadb/ && \
	./fix-permissions.sh /var/log/nginx/ && \
	./fix-permissions.sh /var/run/

COPY startup.sh ./
RUN chmod +x ./startup.sh

# allow volume to be mount on host
VOLUME /var/lib/mysql
VOLUME /app/backend/storage/data

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/startup.sh"]