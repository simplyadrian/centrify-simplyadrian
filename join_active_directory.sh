#!/bin/bash
#
# Copyright (C) 2005-2011 Centrify Corporation.  All Rights Reserved. 
# Any use, modification, redistribution or publication of this file is subject to 
# Express Use license as covered in the Centrify End User License Agreement.
# The complete EULA can be viewed at http://www.centrify.com/eula
#
# Shell script: "Centrify - Join Active Directory"

PATH=/usr/share/centrifydc/kerberos/bin:/usr/share/centrifydc/bin:/usr/sbin:$PATH
BAK_SUFFIX="pre_autojoin"

function debug()
{
    logger -p user.info -t "[$0]DEBUG" "$*"
}

function run()
{
    debug "$*"
    RUN_RESULT=`eval $*`
    RETVAL=$?
    debug "$RUN_RESULT"
    return $RETVAL
}

copy_files()
{
   if [ -f /etc/resolv.conf ]; then
      mv -f /etc/resolv.conf "/etc/resolv.conf.$BAK_SUFFIX"
   fi

# Generate the /etc/resolv.conf file on the fly

   echo "domain $DOMAIN"  >/etc/resolv.conf
   echo "search $DOMAIN" >>/etc/resolv.conf
   echo "nameserver $DNS_IP_ADDRESS" >>/etc/resolv.conf

   cp -f /etc/resolv.conf /etc/resolv.conf.autojoin
 
   # flush nscd cache
   nscdrestart.sh flush
}

function do_join()
{
    local count=1
   
    # User can change the 100 to whatever they have set up in their own environment

    while [ $count -lt 100 ]; do
        run /usr/sbin/adjoin $DOMAIN -w -n "$HOSTNAME_PREFIX$count" -u $AD_JOIN_USERNAME -p $AD_JOIN_PASSWORD
    	if [ $? -eq 0 ]; then
           hostname $HOSTNAME_PREFIX$count
           debug "hostname=$HOSTNAME_PREFIX$count"
           if [ "x`cat /etc/rightscale.d/cloud`" == "xec2" ]; then
              sleep 5
              run /usr/sbin/addns --update --machine --ipaddr `curl http://169.254.169.254/latest/meta-data/public-ipv4`
           fi
	   exit 0
    	fi
        count=`expr $count + 1`
    done

    exit 1
}

debug "DOMAIN=$DOMAIN;HOSTNAME_PREFIX=$HOSTNAME_PREFIX;ATTACH_DIR=$ATTACH_DIR;DNS_IP_ADDRESS=$DNS_IP_ADDRESS"

copy_files

do_join

exit 0
