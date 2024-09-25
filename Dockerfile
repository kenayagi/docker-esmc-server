FROM debian:11

# Set frontend
ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt update && \
    apt-get -y upgrade && \
    apt-get -y --no-install-recommends install \
    ca-certificates \
    cifs-utils \
    krb5-user \
    ldap-utils \
    libsasl2-modules-gssapi-mit \
    lshw \
    netcat \
    openssl \
    procps \
    unixodbc \
    snmp \
    supervisor \
    wget \
    winbind \
    xvfb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Get ODBC Connector
RUN mkdir -p /opt/odbc/
ADD https://downloads.mysql.com/archives/get/p/10/file/mysql-connector-odbc-8.0.33-linux-glibc2.28-x86-64bit.tar.gz /opt/odbc/mysql-connector-odbc.tar.gz
RUN tar --strip-components=1 -x -f /opt/odbc/mysql-connector-odbc.tar.gz -C /opt/odbc/
RUN cp -v /opt/odbc/bin/myodbc-installer /usr/local/bin/
RUN cp -vR /opt/odbc/lib/* /usr/local/lib/
RUN /usr/local/bin/myodbc-installer -a -d -n "MySQL ODBC Driver" -t "Driver=/usr/local/lib/libmyodbc8a.so"

# Get ESET Remote Administrator Server
ADD https://download.eset.com/com/eset/apps/business/era/server/linux/v11/11.1.768.0/server-linux-x86_64.sh /opt/server-linux-x86_64.sh
RUN chmod +x /opt/server-linux-x86_64.sh

# MySQL database settings
ENV DB_HOSTNAME $DB_HOSTNAME
ENV DB_ADMIN_USERNAME $DB_ADMIN_USERNAME
ENV DB_ADMIN_PASSWORD $DB_ADMIN_PASSWORD
ENV DB_USER_USERNAME $DB_USER_USERNAME
ENV DB_USER_PASSWORD $DB_USER_PASSWORD

# Application settings
ENV ERA_ADMINISTRATOR_PASSWORD $ERA_ADMINISTRATOR_PASSWORD
ENV ERA_CERT_HOSTNAME $ERA_CERT_HOSTNAME
ENV ERA_LOCALE $ERA_LOCALE

# Volume
RUN mkdir -p /opt/eset/ /etc/opt/eset/ /var/opt/eset/ /var/log/eset/
VOLUME /etc/opt/eset/
VOLUME /opt/eset/
VOLUME /var/log/eset/
VOLUME /var/opt/eset/

# Ports
EXPOSE 2222 2223

# Scripts
ADD init.sh /usr/local/bin/init.sh
ADD install.sh /usr/local/bin/install.sh
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /usr/local/bin/init.sh /usr/local/bin/install.sh

# Command
WORKDIR /opt/eset/
CMD /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
