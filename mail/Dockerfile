FROM deb-base:latest

LABEL org.opencontainers.image.authors="erwin@emichiels.nl"

RUN groupadd -g 110 dovecot && \
  groupadd -g 111 dovenull && \
  groupadd -g 113 debian-spamd && \
  groupadd -g 118 opendkim && \
  groupadd -g 119 opendmarc && \
  groupadd -g 5000 vmail && \
  useradd -d /var/lib/dovecot -s /bin/false -g dovecot -u 110 dovecot && \
  useradd -d /nonexistent -s /bin/false -g dovenull -u 111 dovenull && \
  useradd -d /var/lib/spamassassin -s /bin/sh -g debian-spamd -u 113 debian-spamd && \
  useradd -d /var/run/opendkim -s /bin/false -g opendkim -u 118 opendkim && \
  useradd -d /var/run/opendmarc -s /bin/false -g opendmarc -u 119 opendmarc && \
  useradd -d /home/vmail -m -s /bin/sh -g vmail -u 5000 vmail && \
  usermod -G postdrop debian-spamd

ENV TZ=Europe/Amsterdam

RUN apt-get update && \
  export DEBIAN_FRONTEND=noninteractive && \
  apt install -y procps --option=Dpkg::Options::=--force-confdef && \
  apt install -q -y postfix-mysql dovecot-common dovecot-pop3d dovecot-imapd dovecot-sieve dovecot-managesieved openssl dovecot-mysql spamassassin spamd spamc spamass-milter tzdata && \
  apt install -q -y libnet-dns-perl libmail-spf-perl pyzor razor opendkim opendkim-tools opendmarc postfix-policyd-spf-python postfix-pcre && \
  apt install -q -y arj cabextract lhasa nomarch unzip zip p7zip bsd-mailx && \
  rm -rf /var/lib/apt/lists/*
RUN cd /usr/lib/postfix && \
  ln -s postfix-mysql.so.1.0.1 dict_mysql.so && \
  mkdir /var/spool/postfix/hold && \
  chown postfix /var/spool/postfix/hold && \
  sed -e "s?/var/log/mail.log?/var/log/qnap/mail.log?" -i /etc/syslog-ng/syslog-ng.conf

RUN dpkg-reconfigure postfix-pcre && \
    postconf -e virtual_uid_maps=static:117 && \
    postconf -e virtual_gid_maps=static:117 && \
    echo 'mail.mydomain.com' > /etc/mailname

# Copy files to root
COPY rootfs /

# SMTP ports
EXPOSE 25
EXPOSE 587  
# POP and IMAP ports  
#EXPOSE 110
#EXPOSE 143
#EXPOSE 995
EXPOSE 993

CMD ["sh", "/start.sh"]
