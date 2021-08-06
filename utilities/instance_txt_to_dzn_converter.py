import sys
import os
import re
from utilities.tools import write_dzn, read_instance_text

if __name__ == "__main__":
    in_path = "./"
    out_path = "./"
    if len(sys.argv) >= 2:
        in_path = sys.argv[1]
    if len(sys.argv) == 3:
        out_path = sys.argv[2]
    files = os.listdir(in_path)

    list_instances = []
    for f in files:
        obj = re.search("^ins-[0-9]+.txt", f)
        if obj is not None:
            width, pieces = read_instance_text(in_path + f)
            f2 = f.replace(".txt", ".dzn")
            # todo decide how to represent pieces in the model so, maybe, we want to change the input data format. 
            write_dzn(width, pieces, out_path+f2)
