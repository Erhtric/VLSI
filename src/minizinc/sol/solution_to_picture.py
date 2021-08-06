import os
import re
from utilities.tools import *
import sys

if __name__ == "__main__":
    in_path = "./"
    out_path = "./"
    if len(sys.argv) >= 2:
        in_path = sys.argv[1]
    if len(sys.argv) == 3:
        out_path = sys.argv[2]
    files = os.listdir(in_path)
    heights = {}
    sol_n = 40
    files = [f"sol-{sol_n}.txt"]
    for f in files:
        obj = re.search("^sol-[0-9]+.txt", f)
        if obj is not None:
            print(f)
            dim, n_circuits, shapes = read_solution_parameters(f)
            heights[f] = dim[1]
            solution = draw_solution(dim, shapes)
            # print(solution)
            new_f = f.replace("txt", "png")
            show_shape(solution, new_f, n_circuits)
    print(heights)
else:
    print("Error")
