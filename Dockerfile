FROM centos:latest
MAINTAINER Stephen Price <steeef@gmail.com>

RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

# Install required packages
RUN yum -y install gcc python-devel bitmap bitmap-fonts python-pip nginx

# Use pip to install graphite, carbon, and deps
RUN pip-python install whisper carbon graphite-web

# Add system service config
#ADD ./nginx.conf /etc/nginx/nginx.conf
#ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
#
## Add graphite config
#add	./initial_data.json /var/lib/graphite/webapp/graphite/initial_data.json
#add	./local_settings.py /var/lib/graphite/webapp/graphite/local_settings.py
#add	./carbon.conf /var/lib/graphite/conf/carbon.conf
#add	./storage-schemas.conf /var/lib/graphite/conf/storage-schemas.conf
#run	mkdir -p /var/lib/graphite/storage/whisper
#run	touch /var/lib/graphite/storage/graphite.db /var/lib/graphite/storage/index
#run	chown -R nginx /var/lib/graphite/storage
#run	chmod 0775 /var/lib/graphite/storage /var/lib/graphite/storage/whisper
#run	chmod 0664 /var/lib/graphite/storage/graphite.db
#run	cd /var/lib/graphite/webapp/graphite && python manage.py syncdb --noinput
#
## Nginx
#expose	80
## Carbon line receiver port
#expose	2003
## Carbon pickle receiver port
#expose	2004
## Carbon cache query port
#expose	7002
#
#cmd	["/usr/bin/supervisord"]
