FROM centos:centos7
MAINTAINER Alexander Bezhenar <bezhenar.alexander@gmail.com>

#Enable the EPEL (Extra Packages for Enterprise Linux) repository
RUN yum -y install epel-release \
 && yum -y update

#Install the required applications, including Python-related tools and the uWSGI with nginx
RUN yum -y install wget gcc python-pip python-devel pycairo libffi-devel \
    pyOpenSSL bitmap bitmap-fonts python-sqlite2 \
    supervisor openssh-server sudo nginx \
 && pip install --upgrade pip

#Get the v 0.9.15 source files for Graphite and Carbon from the GitHub
RUN wget -v --no-verbose -O /tmp/whisper.tar.gz https://github.com/graphite-project/whisper/archive/0.9.15.tar.gz \
 && tar -xzf /tmp/whisper.tar.gz --directory=/tmp/ \
 && cd /tmp/whisper-0.9.15 && /usr/bin/python ./setup.py install \
 && wget -v  --no-verbose -O /tmp/graphite.tar.gz https://github.com/graphite-project/graphite-web/archive/0.9.15.tar.gz \
 && tar -xzf /tmp/graphite.tar.gz --directory=/tmp/ \
 #Install project dependencies
 && pip install -r /tmp/graphite-web-0.9.15/requirements.txt \
 && pip install Django==1.4.11 \
 #(Optional) install python-ldap. Without it, you will not be able to use LDAP authentication in the graphite webapp
 && yum -y install openldap-devel \
 && pip install python-ldap \
 #(Optional) install python-rrdtool. This module is required for reading RRD
 && yum -y install python-rrdtool \
 #Install the web application
 && cd /tmp/graphite-web-0.9.15 && /usr/bin/python ./setup.py install --prefix=/var/lib/graphite --install-lib=/var/lib/graphite/webapp \
 #Install Carbon
 && wget -v  --no-verbose -O /tmp/carbon.tar.gz https://github.com/graphite-project/carbon/archive/0.9.15.tar.gz \
 && tar -xzf /tmp/carbon.tar.gz --directory=/tmp/ \
 && cd /tmp/carbon-0.9.15 && /usr/bin/python ./setup.py install --prefix=/var/lib/graphite --install-lib=/var/lib/graphite/lib \
 && cd / && rm -rf /tmp/*

#to check dependencies use:
##python /usr/local/src/graphite-web/check-dependencies.py

###########Levak
RUN mkdir -p /var/run/sshd \
 && chmod -rx /var/run/sshd

## Add superuser
RUN useradd -d /home/graphite -m -s /bin/bash graphite \
 && echo graphite:graphite | chpasswd \
 && echo 'graphite ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/graphite \
 && chmod 0440 /etc/sudoers.d/graphite

# Add system service config
ADD nginx.conf /etc/nginx/nginx.conf
ADD supervisord.conf /etc/supervisord.conf

## Add graphite config
ADD initial_data.json /var/lib/graphite/webapp/graphite/initial_data.json
ADD local_settings.py /var/lib/graphite/webapp/graphite/local_settings.py
ADD carbon.conf /var/lib/graphite/conf/carbon.conf
ADD storage-schemas.conf /var/lib/graphite/conf/storage-schemas.conf
RUN mkdir -p /var/lib/graphite/storage/whisper \
 && touch /var/lib/graphite/storage/graphite.db /var/lib/graphite/storage/index \
 && chown -R nginx /var/lib/graphite/storage \
 && chmod 0775 /var/lib/graphite/storage /var/lib/graphite/storage/whisper \
 && chmod 0664 /var/lib/graphite/storage/graphite.db
RUN cd /var/lib/graphite/webapp/graphite && python manage.py syncdb --noinput

# Nginx
EXPOSE 80
# Carbon line receiver port
EXPOSE 2003
# Carbon pickle receiver port
EXPOSE 2004
# Carbon cache query port
EXPOSE 7002
# ssh
#EXPOSE 22

ADD start.sh /tmp/start.sh
RUN chmod +x /tmp/start.sh
ENTRYPOINT /tmp/start.sh
