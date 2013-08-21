#!/usr/bin/env python

import sys


def read_input(files):
	for line in files:
	        yield line.strip()



# input comes from STDIN (standard input)
def main():
 	lines_ = read_input(sys.stdin)
	lines=[]
	nLines=0
	firstLocated=False
   	for line in lines_:
           # remove leading and trailing whitespace
        	if not firstLocated:
        #       print line
                # since each mapper will get some random chunk of the file, 
                # the chunk may not start with the FASTQ header.
                # so, we just skip that read. 
                # In general we will loose the number of reads about the number of mappers, i.e. less than 100
                #if line[0]=='@': firstLocated=True; lines.append(''.join(line.split())); nLines=1
        	        if (line[0]=='@'and len(line) < 100): firstLocated=True; lines.append(''.join(line.split())); nLines=0
        	else:
        	        if nLines < 3 :
        	                nLines+=1
        	                lines.append(line)
#                       print line, nLines
        	        else:
        #               print '%s\t%s' % ('FN:head_1;RN:'+lines[0]+';', ' '.join(lines[1:])); 
        	                print '%s\t%s\t%s' % (lines[0], lines[1], lines[3]);
        	                lines=[];lines.append(''.join(line.split())); nLines=0;

if __name__ == "__main__":
	main()

