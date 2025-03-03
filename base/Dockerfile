FROM debian:latest

LABEL org.opencontainers.image.authors="erwin@emichiels.nl"

ARG DEBIAN_FRONTEND="noninteractive"

# Install the relevant packages
RUN groupadd -g 114 postfix && \
  groupadd -g 115 postdrop && \
  groupadd -g 116 ssl-cert && \
  groupadd -g 117 redis && \
  useradd -d /var/spool/postfix -s /bin/false -g postfix -u 114 postfix && \
  useradd -d /var/lib/redis -s /usr/bin/nologin -g redis -u 117 redis

RUN apt update && \
  apt install systemd supervisor syslog-ng gnupg sudo wget apt-transport-https lsb-release ca-certificates vim cron locales openssh-client postfix fail2ban unzip curl -y && \
  apt install net-tools dnsutils iputils-ping -y && \
  apt purge exim4-base exim4-config exim4-daemon-light -y && \
  apt autoremove -y && \
  apt upgrade -y && \
  apt clean -y && \
  rm -rf /var/lib/apt/lists/*

# Add php and mariadb repository
RUN wget https://packages.sury.org/php/apt.gpg && \
  mv apt.gpg /etc/apt/trusted.gpg.d/sury.gpg && \
  echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list

# Add Webmin repository
RUN curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh && \
  sh setup-repos.sh -f

# Disable IPv6 in the kernel
#RUN echo net.ipv6.conf.all.disable_ipv6 = 1 >> /etc/sysctl.conf && \
#  echo net.ipv6.conf.default.disable_ipv6 = 1 >> /etc/sysctl.conf && \
#  echo net.ipv6.conf.lo.disable_ipv6 = 1 >> /etc/sysctl.conf && \
#  echo net.ipv6.conf.eth0.disable_ipv6 = 1 >> /etc/sysctl.conf

# Disable syncookies
#RUN sed -i -e "s/#net.ipv4.tcp_syncookies=1/net.ipv4.tcp_syncookies=1/" /etc/sysctl.conf

# Copy files to root
COPY rootfs /

# Set Timezone to Europe/Amsterdam
RUN echo 'TZ="Europe/Amsterdam"' >> /etc/default/cron && \
  echo "Europe/Amsterdam" > /etc/timezone

# Disable mouse support in vim
#RUN echo "set mouse=" >> /usr/share/vim/vim82/defaults.vim && \
#  echo "set paste" >> /usr/share/vim/vim82/defaults.vim && \
#  echo "syntax off" >> /usr/share/vim/vim82/defaults.vim

# Fix syslog-ng and logrotate
RUN sed -i "/SYSLOGNG_OPTS/s/^#*//" /etc/default/syslog-ng && \
  sed -i "/^\@version/s/3.27/3.35/" /etc/syslog-ng/syslog-ng.conf && \
  rm /etc/logrotate.d/*

CMD ["bash"]
