#!/usr/bin/env python


import sys

def readFile(filename):
    with open(filename) as f:
        content = f.readlines()
    content = [x.strip() for x in content] 
    return content

def createMap(content):
    karta = {}
    for line in content:
        arr = line.split('/')
        yarr = arr[2].split(':')
        if not arr[1] in karta:
            karta[arr[1]] = {}
        karta[arr[1]][yarr[0]] = yarr[1]
    return karta


def writeFile(content, outfile):
    with open(outfile, 'a') as f:
        for key in content:
            f.write('[{}]\n'.format(key))
            for host, value in content[key].items():
                f.write('{} {}\n'.format(host, value))



def main():
    if len(sys.argv) == 3:
        infile  = sys.argv[1]
        outfile = sys.argv[2]
    else:
        print('need 2 args, infile and outfile')
        raise
    f = readFile(infile)
    writeFile(createMap(f), outfile)



if __name__ == '__main__':
    main()
