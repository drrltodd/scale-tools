#! /bin/bash

GPFSPRE=/usr/lpp/mmfs/bin
MMLSDISK=$GPFSPRE/mmlsdisk
MMLSNSD=$GPFSPRE/mmlsnsd

AWK=/usr/bin/gawk

FSNAME="$1"

TMPSTZ=$(mktemp)

# cycle through the disks
$MMLSDISK $FSNAME -Y | tail -n +2 | $AWK -F: '{
    printf ("%%nsd:\n\tnsd=%s\nSERVERS %s\n", $7, $7) ;
    printf ("\tfailureGroup=%s\n", $10) ;
    hasMeta = $11;
    hasData = $12;
    if (hasMeta == "Yes" && hasData == "Yes") {
        usage = "dataAndMetadata" ;
    } else if (hasMeta == "Yes") {
        usage = "metadataOnly" ;
    } else if (hasData == "Yes") {
        usage = "dataOnly" ;
    } else {
        usage = "descOnly" ;
    }
    printf ("\tusage=%s\n\tpool=%s\n\n", usage, $16);
}' > $TMPSTZ

# Add servers lines.
$MMLSNSD -f $FSNAME -Y | tail -n +2 | $AWK -F: "{
     printf (\"sed -e '/^SERVERS %s$/s//\tservers=%s/' -i $TMPSTZ\n\", \$8, \$10);
}" | bash

cat $TMPSTZ
rm -f $TMPSTZ
