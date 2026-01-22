#! /usr/bin/python3

# The script changes lines lengths in text. Reads from an input file, writes to
# an output file.
# Usage:
# ./wordWrap.py input.txt 44 output.txt

import sys, string, argparse, os

parser = argparse.ArgumentParser(description="I/O filenames.")
parser.add_argument('infile', type=str, help='Input filename')
parser.add_argument('linelength', type=int, help='Length of line')
parser.add_argument('outfile', type=str, help='Output filename')
args = parser.parse_args()

infile = os.path.abspath(args.infile)
linelength = args.linelength
outfile = os.path.abspath(args.outfile)
answer = ""

if not(os.path.exists(infile)):
    print(infile + " does not exist.")
    exit(1)

if linelength < 1:
    linelength = 80

if os.path.exists(outfile):
    answer = input(outfile + " already exist.\nOverwrite? [y/N]: ").lower().strip()
    if not(answer in ('y', 'yes')):
        print("Not overwriting existing file.")
        exit(1)

line = space = ""

def main():
    global f, t
    f = open(infile, "r")
    t = open(outfile, "w")
    buf = f.readline()
    while buf != "":
        if len(buf) == 1:
            printline()
            t.write("\n")
        else:
            for word in buf.split():
                addword(word)
        buf = f.readline()
    printline()
    f.close()
    t.close()
    print("\nFile \"" + outfile + "\" was successfully created.\n")

def addword(word):
    global line, space
    if len(line) + len(word) + 1 > linelength:
        printline()
    line = line + space + word
    space = " "

def printline():
    global line, space, t
    if len(line) > 0:
        t.write(line + "\n")
    line = space = ""

main()

