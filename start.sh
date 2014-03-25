#!/bin/bash
ssh-keygen -q -t rsa -f /etc/ssh/ssh_host_rsa_key -C '' -N ''
ssh-keygen -q -t dsa -f /etc/ssh/ssh_host_dsa_key -C '' -N ''
ssh-keygen -q -t rsa1 -f /etc/ssh/ssh_host_key -C '' -N ''
/usr/sbin/sshd -o UseDNS=no -o UsePAM=no

/usr/bin/supervisord
