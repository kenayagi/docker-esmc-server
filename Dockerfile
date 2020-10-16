FROM debian:10

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
    libqtwebkit4 \
    libsasl2-modules-gssapi-mit \
    netcat \
    openssl \
    unixodbc \
    wget \
    winbind \
    xvfb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Get ODBC Connector
RUN mkdir -p /opt/odbc/
ADD https://dev.mysql.com/get/Downloads/Connector-ODBC/5.3/mysql-connector-odbc-5.3.10-linux-debian9-x86-64bit.tar.gz /opt/odbc/mysql-connector-odbc.tar.gz
RUN tar --strip-components=1 -x -f /opt/odbc/mysql-connector-odbc.tar.gz -C /opt/odbc/
RUN cp -v /opt/odbc/bin/myodbc-installer /usr/local/bin/
RUN cp -v /opt/odbc/lib/* /usr/local/lib/
RUN /usr/local/bin/myodbc-installer -a -d -n "MySQL ODBC Driver" -t "Driver=/usr/local/lib/libmyodbc5w.so"
RUN rm -R /opt/odbc/

# Get ESET Remote Administrator Server
ADD https://download.eset.com/com/eset/apps/business/era/server/linux/v7/7.2.2236.0/server-linux-x86_64.sh /opt/server-linux-x86_64.sh
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
VOLUME /var/opt/eset/
VOLUME /var/log/eset/

# Ports
EXPOSE 2222 2223

# Scripts
ADD run.sh /usr/local/bin/run.sh
ADD install.sh /usr/local/bin/install.sh
RUN chmod +x /usr/local/bin/run.sh /usr/local/bin/install.sh

# Command
WORKDIR /opt/eset/
CMD ["/bin/sh","/usr/local/bin/run.sh"]
