#!/usr/bin/python

import sys

def read_input(files):
    for line in files:
        yield line.strip()

def main():
    lines = read_input(sys.stdin)
    for line in lines:
        if (line[0] == "@" and len(line) < 100):
            if not line[-2] == '/':
                line = "%s/1" % line
        print line



if __name__ == "__main__":
    main()
