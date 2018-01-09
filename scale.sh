#! /bin/sh

# This should live in /etc/profile.d/

# General Scale commands
if echo $PATH | egrep -q '^(.*:)?(/i)*/usr/lpp/mmfs/bin(/)*(:.*)?$' ; then
        : skip
else
        PATH=/usr/lpp/mmfs/bin:$PATH
fi
#
# Cloud gateway
if [ -d /opt/ibm/MCStore/bin ]; then
    if echo $PATH | egrep -q '^(.*:)?(/i)*/opt/ibm/MCStore/bin(/)*(:.*)?$' ; then
            : skip
    else
            PATH=/opt/ibm/MCStore/bin:$PATH
    fi
fi
export PATH
