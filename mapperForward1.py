#!/usr/bin/python

import sys
def read_input(files):
	for line in files:
	        yield line.strip()

def main():
	lines = read_input(sys.stdin)
    	for line in lines:
		if (line[0] == "@" and len(line) < 100):
                        print "%s" %line.split('/')[0]+'.1'
                else:
                        print  line



if __name__ == "__main__":
	main()
