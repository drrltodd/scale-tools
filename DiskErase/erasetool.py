#! /usr/bin/env python 


def read_fdisk():
    """Read the output of "fdisk -l", line by line.

    This is written as an iterator so that for testing, the call to
    read_fdisk can be easily replaced by a call to open the test data
    file."""

    from subprocess import Popen, PIPE

    p = Popen(["sudo", "fdisk", "-l"], stdout=PIPE, stderr=PIPE)
    LL,e = p.communicate()
    for L in LL.splitlines():
        yield L


def select_disks():
    """Select disks that have GPFS partitions.

    We only look at disks that use GPT partitioning.

    Returns:
        WHOLE, PART

    where

        WHOLE = list of disks that contain a GPFS partition somewhere
        PART = list of GPFS partitions (potentially several per disk"""

    import re

    # Initialize
    parts = []
    wholeDisks = []

    # Patterns to match output of fdisk
    P1 = re.compile(r'Disk\s+(/dev/\S+):\s')
    P2 = re.compile(r'Disk\s+label\s+type:\s+(\S+)')
    P3 = re.compile(r'\s*\d+\s')
    P4 = re.compile(r'\s*(\d+)\s.*IBM General Par')

    # Parser state
    state = 1

#    for X in open("td"):
    for X in read_fdisk():
        if state is 1:
            # Looking for a disk...
            M = P1.match(X)
            if M:
                targ = M.group(1)
                addWhole = True
                state = 2
            continue
        elif state is 2:
            # Found a disk, looking for partition type
            M = P2.match(X)
            if M:
                if M.group(1) == "gpt":
                    state = 3
                else:
                    state = 1
                continue
        elif state is 3:
            # Found a GPT partitioned disk, looking for first partition
            M = P3.match(X)
            if M:
                state = 4
                # Fall through
            else:
                continue
        if state is 4:
            # Found a GPT partition, keep going until not a partition
            M = P3.match(X)
            if not M:
                state = 1
                continue
            # Still a partition, is it a GPFS partition?
            M = P4.match(X)
            if M:
                # It is a GPFS partition!
                pn = M.group(1)
                parts.append(targ+pn)
                if addWhole:
                    wholeDisks.append(targ)
                    addWhole = False

    # All done.
    return wholeDisks, parts


def main():
    import argparse, sys

    parser = argparse.ArgumentParser(description='Secure erase disks')
    parser.add_argument('-p', '--partitions',
                        action="store_true", default=False,
                       help='Work with partitions, not just whole disks')

    args = parser.parse_args()

    whole, parts = select_disks()
    if args.partitions:
        sys.stdout.write('\n'.join(parts)+'\n')
    else:
        sys.stdout.write('\n'.join(whole)+'\n')

main()
