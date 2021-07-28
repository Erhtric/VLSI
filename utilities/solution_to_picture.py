import numpy as np
import matplotlib.pyplot as plt
import cv2
import json
import matplotlib.patches as mpatches
import sys


# print(sys.argv)
# if len(sys.argv) < 2:
#     print("Error, required at least one argument indicating the file json that represent a solution")
#     sys.exit(1)


def read_parameters(f):
    file = open(f)
    line = file.readline()
    hw = line.strip().split(" ")
    dim = (int(hw[0]), int(hw[1]))
    length = int(file.readline())
    coordinates = []
    for i in range(length):
        line = file.readline()
        split_line = line.replace("\n", "").split(" ")
        coordinates.append(tuple(map(int, split_line)))

    print(coordinates)
    return dim, length, coordinates


def show_shape(s, title, lenght):
    """
    create a image with s as image and title as title of the graph
    :param s: 
    :param title: 
    :return: 
    """
    s = cv2.merge([s])
    img = plt.imshow(s)

    values = np.unique(s)
    colors = [img.cmap(img.norm(value)) for value in values]
    labels = []
    for i in range(lenght):
        labels.append(f"Piece {i + 1}")
    patches = [mpatches.Patch(color=colors[i], label=labels[i]) for i in range(len(values))]
    plt.title(title)
    plt.legend(handles=patches, bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)
    plt.xticks(list(range(0, s.shape[1] + 1)))
    yticks = list(range(0, s.shape[0]))
    # yticks.reverse()
    plt.yticks(yticks)
    plt.ylim(top=s.shape[0])
    plt.ylim(bottom=-0.5)
    plt.xlim(left=-0.5)
    plt.xlim(right=s.shape[1])
    plt.gca().invert_yaxis()
    plt.grid(b=True)
    plt.savefig(f"{title}.png")

    # plt.show()


def draw_solution(arr, pieces):
    count = 1
    for x_t, y_t, x, y in pieces:
        arr[x:x + x_t, y: y + y_t] = count * (250 / len(pieces))
        count += 1
    arr = arr / np.max(arr)
    return np.rot90(arr)


if __name__ == "__main__":
    dim, length, shapes = read_parameters("./sol-1.txt")
    solution = draw_solution(np.zeros(dim), shapes)
    print(solution)
    show_shape(solution, "sol-1.txt", length)

else:
    print("Error")
