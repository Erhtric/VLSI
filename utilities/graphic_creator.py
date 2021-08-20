import matplotlib.pyplot as plt
import json

import numpy as np


def read_json(time_table):
    with open(time_table, "r") as f:
        time_json = json.load(f)
    return time_json


if __name__ == "__main__":
    rot_sym = read_json("../src/smt/time_no_rot_sym.json")
    x = list(range(0,len(rot_sym.values())))
    values = np.asarray(list(rot_sym.values()))
    print(values)
    values[values == -1] = -2
    plt.plot(x, values*1000, "-o")
    # plt.yscale('log', base=10)
    plt.show()
    print(rot_sym)