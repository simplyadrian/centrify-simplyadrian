#!/bin/bash
#
# Copyright (C) 2005-2011 Centrify Corporation.  All Rights Reserved. 
# Any use, modification, redistribution or publication of this file is subject to 
# Express Use license as covered in the Centrify End User License Agreement.
# The complete EULA can be viewed at http://www.centrify.com/eula
#
# Shell script: "Centrify - Setup AD Access and Privilege Management"

function debug()
{
    logger -p user.info -t "[$0]" "$*"
}

function run()
{
    debug "$*"
    RUN_RESULT=`eval $*`
    RETVAL=$?
    debug "$RUN_RESULT"
    return $RETVAL
}

#
# Update sudoers to add privileged group
#

if [ "x`grep -i \"$PRIVILEGE_GROUP\" /etc/sudoers`" == "x" ]; then
   debug "[INFO] - Update /etc/sudoers"
   echo "%$PRIVILEGE_GROUP ALL=(ALL) PASSWD: ALL"      >> /etc/sudoers
fi

#
# Update centrifydc.conf to map root and centrify accounts
#

if [ -f /etc/centrifydc/centrifydc.conf ]; then
    if [ "x`grep -i cloud.root /etc/centrifydc/centrifydc.conf`" == "x" ]; then
       debug "[INFO] - Update /etc/centrifydc/centrifydc.conf"
       echo "pam.mapuser.root:       cloud.root"       >> /etc/centrifydc/centrifydc.conf
       echo "pam.allow.groups:        $ACCESS_GROUP"   >> /etc/centrifydc/centrifydc.conf
       echo "pam.deny.change.shell: false"             >> /etc/centrifydc/centrifydc.conf
       echo "adclient.cache.refresh.group: 180"        >> /etc/centrifydc/centrifydc.conf
       echo "pam.password.enter.mesg: Active Directory Password:\\" >> /etc/centrifydc/centrifydc.conf
       run /etc/init.d/centrifydc restart
    fi
fi

#
# Set up sshd_conf for AD Access and Privilege Management
#

if [ -f /etc/centrifydc/ssh/sshd_config ]; then
    if [ "x`grep -i \"Access and Privilege\" /etc/centrifydc/ssh/sshd_config`" == "x" ]; then
       cp -f /etc/centrifydc/ssh/sshd_config /etc/centrifydc/ssh/sshd_config_ORIGINAL
       debug "[INFO] - Build /etc/centrifydc/ssh/sshd_config"
       echo "# Configuration for Centrify Active Directory Access and Privilege Management" > /etc/centrifydc/ssh/sshd_config
       echo " " >> /etc/centrifydc/ssh/sshd_config
       echo "Protocol 2" >> /etc/centrifydc/ssh/sshd_config
       echo "Subsystem sftp    /usr/share/centrifydc/libexec/sftp-server" >> /etc/centrifydc/ssh/sshd_config
       echo "PermitRootLogin without-password" >> /etc/centrifydc/ssh/sshd_config
       echo "PasswordAuthentication yes" >> /etc/centrifydc/ssh/sshd_config
       echo "UseDNS no" >> /etc/centrifydc/ssh/sshd_config
       echo "ChallengeResponseAuthentication yes" >> /etc/centrifydc/ssh/sshd_config
       echo "Banner /etc/issue" >> /etc/centrifydc/ssh/sshd_config
       echo "GSSAPIKeyExchange yes" >> /etc/centrifydc/ssh/sshd_config
       echo "GSSAPIAuthentication yes" >> /etc/centrifydc/ssh/sshd_config
       echo "GSSAPICleanupCredentials yes" >> /etc/centrifydc/ssh/sshd_config
       echo "UsePAM yes" >> /etc/centrifydc/ssh/sshd_config
       run /etc/init.d/centrify-sshd restart
    fi
fi

#
# Publish Centrify Express Tags to the RightScale Console
#

rs_tag --add 'rs_node:dns_hostname='"$HOSTNAME.`adinfo --domain`"
rs_tag --add 'rs_node:centrify_state='"`adinfo --mode`"
rs_tag --add 'rs_node:ad_hostname='"`adinfo --name`"
rs_tag --add 'rs_node:ad_domain='"`adinfo --domain`"
rs_tag --add 'rs_node:centrify_zone='"`adinfo --zone`"

exit 0
