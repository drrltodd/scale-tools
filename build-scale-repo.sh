#! /bin/sh
#
# This file is provided as-is with no warranty.  Use at your own risk.
#
# Build a Spectrum Scale yum repository file, given a directory of
# directories containing RPMs.

progName=$0
osName=rhel7

Usage() {
    cat 1>&2 <<EOF
Usage:
    $progName [OPTIONS]

OPTIONS are:
    --directory, -d DIR  Get RPMs from under DIR
    --yum, -y YDIR       Use YDIR as the directory of yum repo files
    --os, -o OSNAME      Install on OSNAME
    --object, -O         Include object RPMs
    --create, -c         Use createrepo to regenerate
EOF
}

rpmDir=.
yumDir=/etc/yum.repos.d
objFlag=
crFlag=

state=OPT
for a in $@
do
    case $state in
	OPT)
	    case $a in
		--help|-h|-\?)
		    Usage
		    exit 0
		    ;;
		--dir|--directory|-d)
		    state=GET_DIR
		    ;;
		--yum|-y)
		    state=GET_YUM
		    ;;
        --os|-o)
		    state=GET_OS
		    ;;
		--object|-O)
            objFlag=y
            ;;
		--create|-c)
		    crFlag=y
		    ;;
		-*)
		    echo "$progName: Unknown option \"$a\"" 1>&2
		    Usage
		    exit 1
		    ;;
		*)
		    echo "$progName: Unexpected parameter: $a" 1>&2
		    Usage
		    exit 1
		    ;;
	    esac
	    ;;
	GET_DIR)
	    rpmDir="$a"
	    state=OPT
	    ;;
	GET_OS)
	    osName="$a"
	    state=OPT
	    ;;
	GET_YUM)
	    yumDir="$a"
	    state=OPT
	    ;;
    esac
done
#
case $state in
GET_DIR)
	echo "$progName: Missing required DIR" 1>&2
	Usage
	exit 1
	;;
GET_YUM)
	echo "$progName: Missing required YDIR" 1>&2
	Usage
	exit 1
	;;
esac

# Validate directory arguments.
if [ ! -d "$rpmDir" ]; then
	echo "$progName: Missing rpm directory \"$rpmDir\"" 1>&2
	exit 1
fi
if [ ! -d "$yumDir" ]; then
    echo "$progName: Missing yum repo directory \"$yumDir\"" 1>&2
    exit 1
fi

# Start the repository.
YR=$yumDir/spectrum_scale.repo
cat > "$YR" <<EOF
# Yum repository for IBM Spectrum Scale
# Please remove this when done
#
EOF

for D in "$rpmDir"/*_rpms ; do
    if [ -d "$D" ]; then
	e=$(expr $(basename $D) : '\(.*\)_rpms')
	case $e in
		obj*)
			[ -z "$objFlag" ] && continue
			;;
	esac
	if ls "$D/"*.rpm > /dev/null 2>&1; then
	    cat >> $YR <<EOF

[spectrum_scale_$e]
name=spectrum_scale_$e
baseurl=file://$D
enabled=1
gpgcheck=0
EOF
	fi
        if [ -d "$D/$osName" ]; then
	cat >> $YR <<EOF

[spectrum_scale_${e}_$osName]
name=spectrum_scale_$e_$osName
baseurl=file://$D/$osName
enabled=1
gpgcheck=0
EOF
	fi
    fi
done
