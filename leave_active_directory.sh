#!/bin/bash
#
# Copyright (C) 2005-2011 Centrify Corporation.  All Rights Reserved. 
# Any use, modification, redistribution or publication of this file is subject to 
# Express Use license as covered in the Centrify End User License Agreement.
# The complete EULA can be viewed at http://www.centrify.com/eula
#
# Shell script: "Centrify - Leave Active Directory"

function debug()
{
    logger -p user.info -t "[$0]" "$*"
}

# Try to remove the host from DNS Server first

debug "Remove $HOSTNAME from DNS Server"
/usr/sbin/addns --delete --machine
if [ $? -ne 0 ]; then
   debug "Remove $HOSTNAME from DNS Server Failed! => addns return code = $?"
fi

# Leave the joined domain before terminate

if [ -f /usr/sbin/adleave ]; then
   debug "Leaving AD Domain on Terminate"
   /usr/sbin/adleave -r -u $AD_JOIN_USERNAME -p $AD_JOIN_PASSWORD
   if [ $? -ne 0 ]; then
      debug "Leaving AD Domain on Terminate Failed! => adleave return code = $?"
      exit 1 
   fi
fi

exit 0
