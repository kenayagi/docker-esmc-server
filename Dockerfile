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
#ADD https://download.eset.com/com/eset/apps/business/era/server/linux/latest/server-linux-x86_64.sh /tmp/server-linux-x86_64.sh
#RUN chmod +x /tmp/server-linux-x86_64.sh

# MySQL database settings
#ARG DB_HOSTNAME=era-db
#ENV DB_HOSTNAME=$DB_HOSTNAME

#ENV DB_ADMIN_USERNAME root
#ENV DB_ADMIN_PASSWORD Sisilla322
#ENV DB_USER_USERNAME era
#ENV DB_USER_PASSWORD Candela485

# Application settings
#ENV ERA_ADMINISTRATOR_PASSWORD Avalone334
#ENV ERA_CERT_HOSTNAME era
#ENV ERA_LOCALE it_IT

#RUN echo The MySQL database should be available at ${DB_HOSTNAME}

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
VOLUME /opt/eset/RemoteAdministrator

# Ports
EXPOSE 2222 2223

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Command
ADD run.sh /run.sh
CMD ["/run.sh"]
