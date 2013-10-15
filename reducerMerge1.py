#!/usr/bin/python

# Call with hadoop streaming, setting the following properties:
#
#    hadoop jar ${HADOOP_PREFIX}/contrib/streaming/hadoop-streaming-1.2.1.jar \
#    -Dmap.output.key.field.separator=/ \
#    -Dmapred.text.key.partitioner.options=-k1,1 \
#    -Dmapred.text.key.comparator.options=-k1,1 \
#    -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner \

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
