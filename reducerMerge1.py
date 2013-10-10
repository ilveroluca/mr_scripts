#!/usr/bin/python

import sys

prevId = None
prevRead = None

for line in sys.stdin:
    # the mapper uses tab as the separator between key and value.
    readID, read = line.strip().split('\t', 1)
    readID = readID[0:-2] # drop the trailing /1 or /2
    if prevId:
        if prevId == readID:
            print '\t'.join( (prevId, prevRead, read) )
            prevId = None
        else:
            # dropping an unpaired read
            prevId = readID
            prevRead = read
    else:
        prevId = readID
        prevRead = read
