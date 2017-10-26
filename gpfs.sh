#! /bin/sh

for pathVar in /usr/lpp/mmfs/bin /opt/ibm/MCStore/bin; do
    if [ ! -d $pathVar ]; then
         continue
    fi

    case $PATH in
    *:$pathVar)
	;;
    *:$pathVar:*)
	;;
    $pathVar:*)
	;;
    *)
	PATH=$pathVar:$PATH
	;;
    esac
done
unset pathVar
