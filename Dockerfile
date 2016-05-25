FROM centos:centos7
MAINTAINER Alexander Bezhenar <bezhenar.alexander@gmail.com>

#Enable the EPEL (Extra Packages for Enterprise Linux) repository
RUN yum -y install epel-release \
 && yum -y update

#Install the required applications, including Python-related tools and the uWSGI with nginx
RUN yum -y install git gcc python-pip python-devel pycairo libffi-devel \
    pyOpenSSL bitmap bitmap-fonts python-sqlite2 \
    supervisor openssh-server sudo nginx \
 && pip install --upgrade pip

#Get the latest source files for Graphite and Carbon from the GitHub
RUN cd /usr/local/src \
 && git clone https://github.com/graphite-project/graphite-web.git \
 && git clone https://github.com/graphite-project/carbon.git

#Install project dependencies
RUN pip install -r /usr/local/src/graphite-web/requirements.txt \
 && pip install --upgrade whisper

#(Optional) install python-ldap. Without it, you will not be able to use LDAP authentication in the graphite webapp
RUN yum -y install openldap-devel \
 && pip install python-ldap

#(Optional) install python-rrdtool. This module is required for reading RRD
RUN yum -y install python-rrdtool

#to check dependencies use:
##python /usr/local/src/graphite-web/check-dependencies.py

#Install Carbon
RUN cd /usr/local/src/carbon/ \
 && python setup.py install --prefix=/var/lib/graphite --install-lib=/var/lib/graphite/lib

#Install the web application
RUN cd /usr/local/src/graphite-web/ \
 && python setup.py install --prefix=/var/lib/graphite --install-lib=/var/lib/graphite/webapp


###########Levak
RUN mkdir -p /var/run/sshd \
 && chmod -rx /var/run/sshd

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
#RUN cd /var/lib/graphite/webapp/graphite && python manage.py syncdb --noinput
ENV PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$PATH \
    GRAPHITE_PATH=/var/lib/graphite \
    PYTHONPATH=$PYTHONPATH:$GRAPHITE_ROOT/webapp \
    SECRET_KEY no-so-secret # Fix for your own site!
RUN PYTHONPATH=${GRAPHITE_PATH}/webapp/ django-admin.py migrate --noinput --settings=graphite.settings --run-syncdb

# Nginx
EXPOSE 30080:80
# Carbon line receiver port
EXPOSE 32003:2003
# Carbon pickle receiver port
EXPOSE 32004:2004
# Carbon cache query port
EXPOSE 37002:7002
# ssh
#EXPOSE 30022:22

ADD start.sh /tmp/start.sh
RUN chmod +x /tmp/start.sh
ENTRYPOINT /tmp/start.sh
