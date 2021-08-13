from utilities.tools import *


if __name__ == "__main__":
    # for k in range(1,41):
    for k in [11]:

        dim, n_circuits, coordinates = read_solution_parameters(f"./sol-{k}.txt")
        sol_array = draw_solution(dim, coordinates)
        sat = True
        for i in range(n_circuits):
            for j in range(n_circuits):
                if i != j:
                    if coordinates[i][2] < coordinates[j][2] and coordinates[i][2] + coordinates[i][0] <= \
                            coordinates[j][2]:
                        continue
                    elif coordinates[i][3] < coordinates[j][3] and coordinates[i][3] + coordinates[i][1] <= \
                            coordinates[j][3]:
                        continue
                    elif coordinates[i][2] > coordinates[j][2] and coordinates[i][2] - coordinates[j][0] >= \
                            coordinates[j][2]:
                        continue
                    elif coordinates[i][3] > coordinates[j][3] and coordinates[i][3] - coordinates[j][1] >= \
                            coordinates[j][3]:
                        continue
                    else:
                        print(coordinates[i], coordinates[j])
                        sat = False
        print(f"{k} Sat? {sat}")


