#!/bin/bash
#
# Copyright (C) 2005-2011 Centrify Corporation.  All Rights Reserved. 
# Any use, modification, redistribution or publication of this file is subject to 
# Express Use license as covered in the Centrify End User License Agreement.
# The complete EULA can be viewed at http://www.centrify.com/eula
#
# Shell script: "Centrify - Install Centrify Suite Express"

INSTALL_OPTIONS=""
TARGET_OS="unknown"
OS_REV="unknown"
ARCH="unknown"
PKG_OS_REV="unknown"
RELEASE=""
TRUE=0			### shell uses negative logic.
FALSE=1

function debug()
{
    logger -p user.info -t "[$0]" "$*"
}

normalize_version()
{
    REDUCED=$1
    while REDUCED="`remove_last_0 \"$REDUCED\"`" ; do :; done
    echo "$REDUCED"
}

#
# Detect LINUX version (if OS kernel is unknown)
#
detect_linux ()
{
    if [ -f /etc/enterprise-release ]; then
        debug "/etc/enterprise-release:\n`cat /etc/enterprise-release`" 
        RELEASE="`cat /etc/enterprise-release`"
        case "${RELEASE}" in
        *"Enterprise Linux"*"release 4"*)
            PKG_OS_REV=rhel3
            OS_REV=oracle4;;
        *"Enterprise Linux"*"release 5"*)
            PKG_OS_REV=rhel3
            OS_REV=oracle5;;
        *"Enterprise Linux"*"release 6"*)
            PKG_OS_REV=rhel3
            OS_REV=oracle6;;
        esac
    elif [ -f /etc/redhat-release ]; then
        debug "/etc/redhat-release:\n`cat /etc/redhat-release`" 
        DESKTOP=""
        if [ -n "`cat /etc/redhat-release | grep Client`" ]; then
            DESKTOP="d"
        fi
        RELEASE="`cat /etc/redhat-release`"
        case "${RELEASE}" in
        "Red Hat Linux release 7.2"*)
            ### OS_REV=rh7.2;;
            debug "[ERROR] - Red Hat Linux release 7.2 is not supported anymore."
            exit 0;;
        "Red Hat Linux release 7.3"*)
            ### OS_REV=rh7.3;;
            debug "[ERROR] - Red Hat Linux release 7.3 is not supported anymore."
            exit 0;;
        "Red Hat Linux release 8"*)
            ### OS_REV=rh8;;
            debug "[ERROR] - Red Hat Linux release 8 is not supported anymore."
            exit 0;;
        "Red Hat Linux release 9"*)
            ### OS_REV=rh9;;
            debug "[ERROR] - Red Hat Linux release 9 is not supported anymore."
            exit 0;;
        "Red Hat Enterprise Linux"*"release 2.1"*)
            ### OS_REV=rhel2.1;;
            debug "[ERROR] - Red Hat Enterprise Linux release 2.1 is not supported anymore."
            exit 0;;
        "Red Hat Enterprise Linux"*"release 3"*)
            OS_REV=rhel3;;
        *"Enterprise Linux"*"release 4 ("*" Update 8)")
            PKG_OS_REV=rhel3
            OS_REV=rhel4.8;;
        *"Enterprise Linux"*"release 4"*)
            PKG_OS_REV=rhel3
            OS_REV=rhel4;;
        *"Enterprise Linux"*"release 5 "*)
            PKG_OS_REV=rhel3
            OS_REV=rhel${DESKTOP}5.0;;
        *"Enterprise Linux"*"release 5.1"*)
            PKG_OS_REV=rhel3
            OS_REV=rhel${DESKTOP}5.1;;
        *"Enterprise Linux"*"release 5.2"*)
            PKG_OS_REV=rhel3
            OS_REV=rhel${DESKTOP}5.2;;
        *"Enterprise Linux"*"release 5.3"*)
            PKG_OS_REV=rhel3
            OS_REV=rhel${DESKTOP}5.3;;
        *"Enterprise Linux"*"release 5.4"*)
            PKG_OS_REV=rhel3
            OS_REV=rhel${DESKTOP}5.4;;
        *"Enterprise Linux"*"release 5.5"*)
            PKG_OS_REV=rhel3
            OS_REV=rhel${DESKTOP}5.5;;
        *"Enterprise Linux"*"release 5"*)
            PKG_OS_REV=rhel3
            OS_REV=rhel${DESKTOP}5;;
        *"Enterprise Linux"*"release 6 "*)
            PKG_OS_REV=rhel3
            OS_REV=rhel${DESKTOP}6.0;;
        *"Enterprise Linux"*"release 6"*)
            PKG_OS_REV=rhel3
            OS_REV=rhel${DESKTOP}6;;
        "Fedora Core release 2"*)
            ### rhfc2 is still supported
            PKG_OS_REV=rhel3
            OS_REV=rhfc2;;
        "Fedora Core release 3"*)
            ### OS_REV=rhfc3;;
            debug "[ERROR] - Fedora Core release 3 is not supported anymore."
            exit 0;;
        "Fedora Core release 4"*)
            ### PKG_OS_REV=rhel3
            ### OS_REV=rhfc4;;
            debug "[ERROR] - Fedora Core release 4 is not supported anymore."
            exit 0;;
        "Fedora Core release 5"*)
            ### PKG_OS_REV=rhel3
            ### OS_REV=rhfc5;;
            debug "[ERROR] - Fedora Core release 5 is not supported anymore."
            exit 0;;
        "Fedora Core release 6"*)
            ### PKG_OS_REV=rhel3
            ### OS_REV=rhfc6;;
            debug "[ERROR] - Fedora Core release 6 is not supported anymore."
            exit 0;;
        "Fedora"*"release 7"*)
            ### PKG_OS_REV=rhel3
            ### OS_REV=rhfc7;;
            debug "[ERROR] - Fedora Core release 7 is not supported anymore."
            exit 0;;
        "Fedora"*"release 8"*)
            ### PKG_OS_REV=rhel3
            ### OS_REV=rhfc8;;
            debug "[ERROR] - Fedora Core release 8 is not supported anymore."
            exit 0;;
        "Fedora"*"release 9"*)
            PKG_OS_REV=rhel3
            OS_REV=rhfc9;;
        "Fedora"*"release 10"*)
            PKG_OS_REV=rhel3
            OS_REV=rhfc10;;
        "Fedora"*"release 11"*)
            PKG_OS_REV=rhel3
            OS_REV=rhfc11;;
        "Fedora"*"release 12"*)
            PKG_OS_REV=rhel3
            OS_REV=rhfc12;;
        "Fedora"*"release 13"*)
            PKG_OS_REV=rhel3
            OS_REV=rhfc13;;
        "Red Hat Linux Advanced Server release 2.1AS"*)
            ### OS_REV=centos2.1;;
            debug "[ERROR] - CentOS 2.1 is not supported anymore."
            exit 0;;
        "CentOS release 3.8"*)
            ### PKG_OS_REV=rhel3
            ### OS_REV=centos3.8;;
            debug "[ERROR] - CentOS 3.8 is not supported anymore."
            exit 0;;
        "CentOS release 3.9"*)
            ### PKG_OS_REV=rhel3
            ### OS_REV=centos3.9;;
            debug "[ERROR] - CentOS 3.9 is not supported anymore."
            exit 0;;
        "CentOS release 4.4"*)
            PKG_OS_REV=rhel3
            OS_REV=centos4.4;;
        "CentOS release 4.5"*)
            PKG_OS_REV=rhel3
            OS_REV=centos4.5;;
        "CentOS release 4.6"*)
            PKG_OS_REV=rhel3
            OS_REV=centos4.6;;
        "CentOS release 4.7"*)
            PKG_OS_REV=rhel3
            OS_REV=centos4.7;;
        "CentOS release 4.8"*)
            PKG_OS_REV=rhel3
            OS_REV=centos4.8;;
        "CentOS release 5.0"*)
            PKG_OS_REV=rhel3
            OS_REV=centos5.0;;
        "CentOS release 5.1"*)
            PKG_OS_REV=rhel3
            OS_REV=centos5.1;;
        "CentOS release 5.2"*)
            PKG_OS_REV=rhel3
            OS_REV=centos5.2;;
        "CentOS release 5.3"*)
            PKG_OS_REV=rhel3
            OS_REV=centos5.3;;
        "CentOS release 5.4"*)
            PKG_OS_REV=rhel3
            OS_REV=centos5.4;;
        "CentOS release 5.5"*)
            PKG_OS_REV=rhel3
            OS_REV=centos5.5;;
        "CentOS release 5"*)
            PKG_OS_REV=rhel3
            OS_REV=centos5;;
        "CentOS release 6"*)
            PKG_OS_REV=rhel3
            OS_REV=centos6;;
        "Scientific Linux"*"release 3.0.8"*)
            ### PKG_OS_REV=rhel3
            ### OS_REV=scientific3.0.8;;
            debug "[ERROR] - Scientific Linux 3.0.8 is not supported anymore."
            exit 0;;
        "Scientific Linux"*"release 3.0.9"*)
            ### PKG_OS_REV=rhel3
            ### OS_REV=scientific3.0.9;;
            debug "[ERROR] - Scientific Linux 3.0.9 is not supported anymore."
            exit 0;;
        "Scientific Linux"*"release 4.4"*)
            PKG_OS_REV=rhel3
            OS_REV=scientific4.4;;
        "Scientific Linux"*"release 4.5"*)
            PKG_OS_REV=rhel3
            OS_REV=scientific4.5;;
        "Scientific Linux"*"release 4.6"*)
            PKG_OS_REV=rhel3
            OS_REV=scientific4.6;;
        "Scientific Linux"*"release 4.7"*)
            PKG_OS_REV=rhel3
            OS_REV=scientific4.7;;
        "Scientific Linux"*"release 4.8"*)
            PKG_OS_REV=rhel3
            OS_REV=scientific4.8;;
        "Scientific Linux"*"release 5.0"*)
            PKG_OS_REV=rhel3
            OS_REV=scientific5.0;;
        "Scientific Linux"*"release 5.1"*)
            PKG_OS_REV=rhel3
            OS_REV=scientific5.1;;
        "Scientific Linux"*"release 5.2"*)
            PKG_OS_REV=rhel3
            OS_REV=scientific5.2;;
        "Scientific Linux"*"release 5.3"*)
            PKG_OS_REV=rhel3
            OS_REV=scientific5.3;;
        "Scientific Linux"*"release 5.4"*)
            PKG_OS_REV=rhel3
            OS_REV=scientific5.4;;
        "Scientific Linux"*"release 5.5"*)
            PKG_OS_REV=rhel3
            OS_REV=scientific5.5;;
        "Scientific Linux"*"release 5"*)
            PKG_OS_REV=rhel3
            OS_REV=scientific5;;
        "Scientific Linux"*"release 6"*)
            PKG_OS_REV=rhel3
            OS_REV=scientific6;;
        "Mandriva Linux release 2008"*)
            ### PKG_OS_REV=rhel3
            ### OS_REV=mdv2008;;
            debug "[ERROR] - Mandriva Linux 2008 is not supported anymore."
            exit 0;;
        "Mandriva Linux release 2009.1"*)
            PKG_OS_REV=rhel3
            OS_REV=mdv2009.1;;
        "Mandriva Linux release 2009"*)
            PKG_OS_REV=rhel3
            OS_REV=mdv2009;;
        "Mandriva Linux release 2010.1"*)
            PKG_OS_REV=rhel3
            OS_REV=mdv2010.1;;
        "Mandriva Linux release 2010"*)
            PKG_OS_REV=rhel3
            OS_REV=mdv2010;;
        "Mandriva Linux Enterprise Server release 5"*)
            PKG_OS_REV=rhel3
            OS_REV=mdves5;;
        "XenServer release 4.1"*"xenenterprise"*)
            PKG_OS_REV=rhel3
            OS_REV=xen4.1;;
        "XenServer release 4"*"xenenterprise"*)
            PKG_OS_REV=rhel3
            OS_REV=xen4;;
        "XenServer release 5.5"*"xenenterprise"*)
            PKG_OS_REV=rhel3
            OS_REV=xen5.5;;
        "XenServer release 5.6"*"xenenterprise"*)
            PKG_OS_REV=rhel3
            OS_REV=xen5.6;;
        "XenServer release 5"*"xenenterprise"*)
            PKG_OS_REV=rhel3
            OS_REV=xen5;;
        esac
    elif [ -f /etc/SuSE-release ]; then
        debug "/etc/SuSE-release:\n`cat /etc/SuSE-release`" 
        OPEN=""
        DESKTOP=""
        if [ -n "`cat /etc/SuSE-release | grep open`" ]; then
            OPEN="open"
        elif [ -n "`cat /etc/SuSE-release | grep Desktop`" ]; then
            DESKTOP="d"
        fi
        RELEASE="`grep VERSION /etc/SuSE-release | sed s'/VERSION = //'`"
        RELEASE="`normalize_version \"$RELEASE\"`"
        if [ -z "$OPEN" ]; then
            if [ -n "$DESKTOP" ]; then
                case "${RELEASE}" in
                8 | 8.* | 9 | 9.* )
                    ### PKG_OS_REV=suse8
                    ### OS_REV=suse${DESKTOP}${RELEASE}
                    debug "[ERROR] -  SuSE Desktop ${RELEASE} is not supported anymore."
                    exit 0
                    ;;
                10 | 10.* )
                    PKG_OS_REV=suse8
                    OS_REV=suse${DESKTOP}10;;
                11 | 11.* )
                    PKG_OS_REV=suse8
                    OS_REV=suse${DESKTOP}11;;
                esac
            else
                case "${RELEASE}" in
                8 | 8.* )
                    PKG_OS_REV=suse8
                    OS_REV=suse8;;
                9 | 9.* )
                    PKG_OS_REV=suse8
                    OS_REV=suse9;;
                10 | 10.* )
                    PKG_OS_REV=suse8
                    OS_REV=suse10;;
                11 | 11.* )
                    PKG_OS_REV=suse8
                    OS_REV=suse11;;
               esac
            fi
        else
            case "${RELEASE}" in
            10 | 10.* )
                ### PKG_OS_REV=suse8
                ### OS_REV=opensuse${RELEASE};;
                debug "[ERROR] - openSUSE ${RELEASE} are not supported anymore."
                exit 0
                ;;
            11 | 11.[1-3] )
                if [ "$RELEASE" = "11" ]; then RELEASE="11.0"; fi
                PKG_OS_REV=suse8
                OS_REV=opensuse${RELEASE};;
            11 | 11.* )
                PKG_OS_REV=suse8
                OS_REV=opensuse11;;
            esac
        fi
    elif [ -f /etc/UnitedLinux-release ]; then
        debug "/etc/UnitedLinux-release:\n`cat /etc/UnitedLinux-release`" 
        RELEASE="`cat /etc/UnitedLinux-release | grep VERSION`"
        case "${RELEASE}" in
        "VERSION = 1."*)
            OS_REV=suse8;;
        esac
    elif [ -f /etc/lsb-release ]; then
        echo ${ECHO_FLAG} "INFO: /etc/lsb-release:\n`cat /etc/lsb-release`" 
        if [ "`uname -r | grep generic ; echo $?`" = "0" ]; then
            if [ "`uname -r | grep pae ; echo $?`" = "0" ]; then
                KERNEL_CFG="s" # server with Physical Address Extension
            else
                KERNEL_CFG="d" # desktop
            fi
        else
            KERNEL_CFG="s" # server
        fi
        RELEASE="`grep DISTRIB_RELEASE /etc/lsb-release | sed 's/DISTRIB_RELEASE=//'`"
        RELEASE_YEAR="`echo \"$RELEASE\" | sed -e 's/\..*//'`"
        RELEASE_MONTH="`echo \"$RELEASE\" | sed -e 's/[^\.]*\.//' -e 's/\..*//'`"
        case "${RELEASE_YEAR}" in
        [6-9] | 10 )
            if [ "$RELEASE_YEAR" = 6 ]; then
                case "${RELEASE_MONTH}" in
                0[7-9] | 1[0-2] )
                    RELEASE_YEAR=`expr $RELEASE_YEAR + 1`
                    RELEASE_MONTH=04
                    ;;
                0[1-6] | * )
                    RELEASE_MONTH=06
                    ;;
                esac
            else
                case "${RELEASE_MONTH}" in
                1[1-2]* )
                    RELEASE_YEAR=`expr $RELEASE_YEAR + 1`
                    RELEASE_MONTH=04
                    ;;
                0[1-4]* )
                    RELEASE_MONTH=04
                    ;;
                0[5-9]* | 10 | * )
                    RELEASE_MONTH=10
                    ;;
                esac
            fi
            PKG_OS_REV=deb5
            OS_REV=ubuntu${KERNEL_CFG}${RELEASE_YEAR}.${RELEASE_MONTH};;
        esac

        case "${OS_REV}" in
        ubuntud7.04 | ubuntud7.10 | ubuntus7.04 | ubuntus7.10 )
            debug "[ERROR] - Ubuntu ${RELEASE_YEAR}.${RELEASE_MONTH} is not supported anymore."
            exit 0
            ;;
        esac
    elif [ -f /etc/debian_version ] && [ "${OS_REV}" = "unknown" ]; then
        debug "/etc/debian_version:\n`cat /etc/debian_version`" 
        RELEASE="`cat /etc/debian_version`"
        case "${RELEASE}" in
        "3.0"*)
            ### OS_REV=deb3.0;;
            debug "[ERROR] - Debian 3.0 is not supported anymore."
            exit 0;;
        "3.1"*)
            ### OS_REV=deb3.1;;
            debug "[ERROR] - Debian 3.1 is not supported anymore."
            exit 0;;
        "4."*)
            ### OS_REV=deb4;;
            debug "[ERROR] - Debian 4 is not supported anymore."
            exit 0;;
        "5."*)
            OS_REV=deb5;;
        esac
    fi
} # detect_linux()

#
# Detect OS, OS revision, architecture (hardware-platform)
#
detect_os ()
{
    ### run detect_os only once, if PKG_OS_REV is set already then just return
    if [ "${PKG_OS_REV}" != "unknown" ]; then return $TRUE; fi
    echo Detecting local platform ...
    case "`uname -s`" in
    Linux*)
        TARGET_OS=linux
        EXPRESS_PL=$TRUE
        case "`uname -r`" in
        2.2.20* )
            ### OS_REV=deb3.0;;
            debug "[ERROR] - Debian 3.0 is not supported anymore."
            exit 0;;
        2.4.7*)
            ### OS_REV=rh7.2;;
            debug "[ERROR] - Red Hat Linux release 7.2 is not supported anymore."
            exit 0;;
        2.4.9-34* | 2.4.9-vmnix2*)
            OS_REV=esx2;;
        2.4.18-3*)
            ### OS_REV=rh7.3;;
            debug "[ERROR] - Red Hat Linux release 7.3 is not supported anymore."
            exit 0;;
        2.4.18-14*)
            ### OS_REV=rh8;;
            debug "[ERROR] - Red Hat Linux release 8 is not supported anymore."
            exit 0;;
        2.4.19-* | 2.4.21-198*) # SLES8
            OS_REV=suse8;;
        2.4.20-6* | 2.4.20-8*) # RH9
            ### OS_REV=rh9;;
            debug "[ERROR] - Red Hat Linux release 9 is not supported anymore."
            exit 0;;
        2.4.21-15* | 2.4.21-32*) # RHEL 3
            OS_REV=rhel3;;
        2.4.21-47*) # CentOS 3.8 or Scientific 3.0.8
            PKG_OS_REV=rhel3
            OS_REV=centos3.8;;
        2.6.5-1.358*) # FC2
            ### rhfc2 is still supported
            PKG_OS_REV=rhel3
            OS_REV=rhfc2;;
        2.6.5-7* | 2.6.8-24*) # SLES9
            PKG_OS_REV=suse8
            OS_REV=suse9;;
        2.6.9-1*)
            ### OS_REV=rhfc3;;
            debug "[ERROR] - Fedora Core release 3 is not supported anymore."
            exit 0;;
        2.6.9-5.EL* | 2.6.9-22.* | 2.6.9-34.* | 2.6.9-42.*)
            PKG_OS_REV=rhel3
            OS_REV=rhel4;;
        2.6.9-55.*)
            PKG_OS_REV=rhel3
            OS_REV=scientific4.5;;
        2.6.11-1.*)
            PKG_OS_REV=rhel3
            OS_REV=rhfc4;;
        2.6.13-15* | 2.6.16-rc1* | 2.6.16.13* | 2.6.16.21* | 2.6.16.60* ) # SLES10
            PKG_OS_REV=suse8
            OS_REV=suse10;;
        2.6.15-1.*)
            PKG_OS_REV=rhel3
            OS_REV=rhfc5;;
        2.6.18-1.*)
            PKG_OS_REV=rhel3
            OS_REV=rhfc6;;
        2.6.18-8.* | 2.6.18-53.*)
            PKG_OS_REV=rhel3
            OS_REV=rhel5;;
        2.6.20-15*)
            PKG_OS_REV=deb5
            OS_REV=ubuntu7.04;;
        2.6.21-1.*)
            PKG_OS_REV=rhel3
            OS_REV=rhfc7;;
        2.6.23.1-*)
            PKG_OS_REV=rhel3
            OS_REV=rhfc8;;
        *)
            debug "[INFO] - Unknown kernel: `uname -r`. Calling detect_linux..." 
            ;;
        esac
        detect_linux
        if [ "${OS_REV}" = "unknown" ]; then
            debug "[ERROR] - Unknown OS revision: `uname -r`"
            exit 0
        fi
        if [ "`uname -m`" = "i686" ]; then
            ARCH=i386
        elif [ "`uname -m`" = "x86_64" ]; then
            ARCH=x86_64
            case ${OS_REV} in
            rhel3 | rhel4 | rhel5 | rhel5.0 | rhel5.1 | rhel5.2 | rhel5.3 | rhel5.4 | rhel5.5 | rhel6 | rhel6.0 | \
            rheld5 | rheld5.0 | rheld5.1 | rheld5.2 | rheld5.3 | rheld5.4 | rheld5.5 | rheld6 | rheld6.0 | \
            rhfc3 | rhfc4 | rhfc5 | rhfc6 | rhfc7 | rhfc8 | rhfc9 | rhfc10 | rhfc11 | rhfc12 | rhfc13 | \
            oracle4 | oracle5 | oracle6 | \
            centos3.8 | centos3.9 | centos4.4 | centos4.5 | centos4.6 | centos4.7 | centos4.8 | \
            centos5.0 | centos5.1 | centos5.2 | centos5.3 | centos5.4 | centos5.5 | centos5 | centos6 | \
            scientific3.0.8 | scientific3.0.9 | scientific4.4 | scientific4.5 | scientific4.6 | scientific4.7 | scientific4.8  | \
            scientific5.0 | scientific5.1 | scientific5.2 | scientific5.3 | scientific5.4 | scientific5.5 | scientific5 | scientific6 | \
            mdves5 )
                PKG_OS_REV=rhel3;;
            suse9* | suse10* | suse11* | sused9* | sused10* | sused11* | opensuse10* | opensuse11*)
                PKG_OS_REV=suse9;;
            esac
        else
            debug "[ERROR] - Unknown hardware-platform: `uname -m`"
            exit 0
        fi
        case ${OS_REV} in
        rhfc2 | esx* | xen* )
            EXPRESS_PL=$FALSE
        esac
        ;;
    *)
        debug "[ERROR] - Unknown target OS: `uname -s`"
        exit 0;;
    esac
    if [ "${PKG_OS_REV}" = "unknown" ]; then PKG_OS_REV=${OS_REV}; fi
    debug "[INFO] - TARGET_OS=${TARGET_OS}" 
    debug "[INFO] - OS_REV=${OS_REV}" 
    debug "[INFO] - ARCH=${ARCH}" 
    if [ "${EXPRESS_PL}" -eq $TRUE ]; then
        debug "[INFO] - Express mode is supported" 
    else
        debug "[INFO] - Express mode is not supported" 
    fi
} # detect_os()

#
# Skip this script on reboot.
#
if test "$RS_REBOOT" = "true" ; then
  exit 0
fi

#
# Use initctl to stop sshd if /etc/init/ssh.conf exits and remove it from Upstart list
#
if [ -f /etc/init/ssh.conf ]; then
   debug "initctl stop ssh"
   initctl stop ssh
   mv /etc/init/ssh.conf /etc/init/ssh.conf-UPSTART
fi

#
# Get the correct ARCH and PKG_OS_REV based on the OS type and machine type
#
detect_os

#
# Download Centrify Suite
#

cd /tmp
debug "curl -s -L -o centrify-suite-$PKG_OS_REV-$ARCH.tgz \"http://www.centrify.com/_services/get/centrify-suite.asp?BasePlatform=linux&OSType=$OS_REV&Processor=$ARCH&Version=latest\""

curl -s -L -o centrify-suite-$PKG_OS_REV-$ARCH.tgz "http://www.centrify.com/_services/get/centrify-suite.asp?BasePlatform=linux&OSType=$OS_REV&Processor=$ARCH&Version=latest"

if [ $? -eq 0 ]; then

   tar zxf centrify-suite-$PKG_OS_REV-$ARCH.tgz
   cp /dev/null /var/log/centrifydc-install.log

   if [ -f $ATTACH_DIR/centrifydc-express-install.cfg ]; then
      INSTALL_OPTIONS="--suite-config $ATTACH_DIR/centrifydc-express-install.cfg"
   else
      if [ -f centrify-suite.cfg ]; then
         sed -e 's/ADLICENSE.*/ADLICENSE="N"/' \
               -e 's/^CentrifyDC_nis.*/CentrifyDC_nis=/' \
               -e 's/^CentrifyDC_krb5.*/CentrifyDC_krb5=/' \
               -e 's/^CentrifyDA.*/CentrifyDA=/' \
               centrify-suite.cfg >centrify-suite-express.cfg
         INSTALL_OPTIONS="--suite-config centrify-suite-express.cfg"
     fi
   fi

   debug "/tmp/install-express.sh --express $INSTALL_OPTIONS"
   if [ -f /tmp/install-express.sh ]; then
      /tmp/install-express.sh --express $INSTALL_OPTIONS
   fi

else
   debug "[ERROR] - Downloading Centrify Express Suite failed: `cat centrify-suite-$PKG_OS_REV-$ARCH.tgz`"
   exit 1
fi

exit 0
