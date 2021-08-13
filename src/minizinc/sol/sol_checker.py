from utilities.tools import *


if __name__ == "__main__":
    # for k in range(1,41):
    for k in [11]:
        dim, n_circuits, coordinates = read_solution_parameters(f"./sol-{k}.txt")
        sol_array = draw_solution(dim, coordinates)
        sat = check_sat(dim,coordinates)
        print(f"{k} Sat? {sat}")


