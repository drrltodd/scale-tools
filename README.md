# scale-tools

These are some tools for working with Spectrum Scale (GPFS).  They are provided as-is, with no promise whatsoever that they will be useful.

* build-scale-repo.sh
  This tool will create `yum` repositories from the directories unpacked by the Spectrum Scale installer.  (NB The -c option was not implemented, probably isn't really needed.)

* scale.sh
  This is a "piece file" for /etc/profile.d to add Spectrum Scale commands to the PATH.  It will add TCT commands too.  It takes steps to make sure the directories are only added once.

* DiskErase
  This tool is not complete.  The intent is to be able to securely erase disks that previously had GPFS installed on them.  What it should be able to do is identify the partitions that have had GPFS installed on them.  But erase them?  Overwriting can be added, but with SSDs and virtualized storage, we are limited in what we can do (better to use encrypting disks if this is a consideration!).