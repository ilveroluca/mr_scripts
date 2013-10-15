#!/usr/bin/env python

# Call with hadoop streaming, setting the following properties:
#
#    hadoop jar ${HADOOP_PREFIX}/contrib/streaming/hadoop-streaming-1.2.1.jar \
#    -Dmap.output.key.field.separator=/ \
#    -Dmapred.text.key.partitioner.options=-k1,1 \
#    -Dmapred.text.key.comparator.options=-k1,1 \
#    -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner \
# 

import sys


def read_input(files):
    for line in files:
        # remove tabs,trailing whitespace and newline
        yield line.rstrip().replace('\t', ' ')

# input comes from STDIN (standard input)
def main():
    lines_ = read_input(sys.stdin)
    lines=[]
    nLines=0
    firstLocated=False

    # since each mapper will get some random chunk of the file,
    # the chunk may not start with the FASTQ header.
    # so, we just skip that read.
    # In general we will lose the number of reads about the number of mappers, i.e. less than 100
    for line in lines_:
        if not firstLocated:
            # since each mapper will get some random chunk of the file,
            # the chunk may not start with the FASTQ header.
            # so, we just skip that read.
            # In general we will lose the number of reads about the number of mappers, i.e. less than 100
            if line[0]=='@' and len(line) < 100:
                firstLocated=True
                lines.append(line)
                nLines=0
        else:
            if nLines < 3:
                nLines+=1
                lines.append(line)
                #   print line, nLines
            else:
                #   print '%s\t%s' % ('FN:head_1;RN:'+lines[0]+';', ' '.join(lines[1:]));
                print '\t'.join( (lines[0], lines[1], lines[3]) )
                lines = [ line ]
                nLines = 0

if __name__ == "__main__":
    main()
