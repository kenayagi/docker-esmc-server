FROM debian:9

# Set frontend
ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y --no-install-recommends install \
    unixodbc xvfb cifs-utils libqtwebkit4 krb5-user \
    winbind ldap-utils libsasl2-modules-gssapi-mit wget

# Get ODBC Connector
RUN mkdir -p /opt/odbc/
WORKDIR /opt/odbc/
ADD https://dev.mysql.com/get/Downloads/Connector-ODBC/5.3/mysql-connector-odbc-5.3.9-linux-debian8-x86-64bit.tar.gz /opt/odbc/mysql-connector-odbc.tar.gz
RUN tar --strip-components=1 -x -f /opt/odbc/mysql-connector-odbc.tar.gz -C /opt/odbc/
RUN cp -v /opt/odbc/bin/myodbc-installer /usr/local/bin/
RUN cp -v /opt/odbc/lib/* /usr/local/lib/
RUN /usr/local/bin/myodbc-installer -a -d -n "MySQL ODBC Driver" -t "Driver=/usr/local/lib/libmyodbc5w.so"

# Get ESET Remote Administrator Server
ADD https://download.eset.com/com/eset/apps/business/era/server/linux/latest/server-linux-x86_64.sh /opt/server-linux-x86_64.sh
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

#RUN /tmp/server-linux-x86_64.sh \
#    --db-driver "MySQL ODBC Driver" \
#    --db-hostname ${DB_HOSTNAME} \
#    --db-admin-username ${DB_ADMIN_USERNAME} \
#    --db-admin-password ${DB_ADMIN_PASSWORD} \
#    --db-user-username ${DB_USER_USERNAME} \
#    --db-user-password ${DB_USER_PASSWORD} \
#    --server-root-password ${ERA_ADMINISTRATOR_PASSWORD} \
#    --cert-hostname ${ERA_CERT_HOSTNAME} \
#    --locale ${ERA_LOCALE} \
#    --skip-license

# Volume
VOLUME /etc/opt/eset/RemoteAdministrator

# Ports
EXPOSE 2222 2223

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Command
COPY run.sh /usr/local/bin/run.sh
COPY install.sh /usr/local/bin/install.sh
CMD ["/usr/local/bin/run.sh"]
