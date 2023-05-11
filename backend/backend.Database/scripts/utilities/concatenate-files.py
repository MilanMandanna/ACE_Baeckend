import time, glob, sys

if len(sys.argv) < 2:
    print("Usage: concatenate-files.py <output filename> <glob pattern> [<glob pattern>]")
    sys.exit(0)

outfilename = sys.argv[1]

with open(outfilename, 'w') as outfile:
    
    for i in range(1, len(sys.argv)):
        
        pattern = sys.argv[i]
        filenames = glob.glob(pattern)

        for fname in filenames:
            print('found: %s' % (fname))
            with open(fname, 'r', encoding='utf_8_sig') as readfile:
                for line in readfile:
                    outfile.write(line)
                #infile = readfile.read()
                #u = infile.decode("utf-8-sig")
                #for line in infile:
                #    outfile.write(line)
                outfile.write("\nGO\n\n")

