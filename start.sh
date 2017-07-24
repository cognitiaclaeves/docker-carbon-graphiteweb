#!/bin/bash
if [ -n "${SECRET_KEY}" ]; then
      sed -E -i "s/^environment = (.*)$/environment = \1,SECRET_KEY='$SECRET_KEY'/" /etc/supervisord.conf
fi

ssh-keygen -q -t rsa -f /etc/ssh/ssh_host_rsa_key -C '' -N ''
ssh-keygen -q -t dsa -f /etc/ssh/ssh_host_dsa_key -C '' -N ''
ssh-keygen -q -t rsa1 -f /etc/ssh/ssh_host_key -C '' -N ''

/usr/bin/supervisord
# /usr/sbin/sshd -D -o UseDNS=no -o UsePAM=no

