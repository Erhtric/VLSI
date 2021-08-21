from utilities.tools import *

ROTATION = 0
if __name__ == "__main__":
    # for k in range(1, 41):
    for k in [11]:
        if ROTATION == 0:
            if k < 10:
                file = f"./sol-0{k}.txt"
            else:
                file = f"./sol-{k}.txt"
            dim, n_circuits, coordinates = read_solution_parameters(file)
            sat = check_sat(dim, coordinates)
            print(f"{k} Sat? {sat}")
        else:
            if k < 10:
                file = f"./sol-0{k}-rot.txt"
            else:
                file = f"./sol-{k}.txt"
            dim, n_circuits, coordinates = read_solution_parameters(file)
            sat = check_sat_rot(dim, coordinates)
            print(f"{k} Sat? {sat}")
