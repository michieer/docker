FROM debian:latest

LABEL org.opencontainers.image.authors="erwin@emichiels.nl"

ARG DEBIAN_FRONTEND="noninteractive"

ENV TZ=Europe/Amsterdam

RUN apt update && \
  apt install -y procps --option=Dpkg::Options::=--force-confdef && \
  apt install systemd supervisor syslog-ng gnupg sudo wget apt-transport-https lsb-release ca-certificates vim cron locales openssh-client postfix fail2ban unzip curl -y && \
  apt install mariadb-server -y && \
  rm -rf /var/lib/apt/lists/*

# Copy files to root
COPY rootfs /

CMD mkdir /var/log/mysql &&  \
  chown -R mysql:mysql /var/log/mysql

RUN locale-gen

EXPOSE 3306

CMD ["sh", "/start.sh"]
