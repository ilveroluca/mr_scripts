#!/usr/bin/python

import sys

from itertools import izip, islice

f1 = open(sys.argv[1], 'r')
f2 = open(sys.argv[2], 'r')

def read_input(f):
		for line in f:
			yield line.rstrip()

def split_every(n, i):
	piece = list(islice(i, n))
	while piece:
		yield piece
		piece = list(islice(i, n))

def main():
	lines1 = read_input(f1)
	lines2 = read_input(f2)
	
	list1_ =  split_every(4,lines1)
	list2_ =  split_every(4,lines2)

	
	for line1, line2 in izip(list1_, list2_):
		if len(line1)==4:
			print '%s\t%s\t%s\t%s\t%s\t%s' %(line1[0], line1[1], line1[3], line2[0], line2[1], line2[3])#, line2

if __name__ == "__main__":
        main()

