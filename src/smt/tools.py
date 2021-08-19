import numpy as np
from z3 import *
import numpy as np
import matplotlib.pyplot as plt
import cv2
import matplotlib.patches as mpatches

def read_instance_text(f):
    """ 
    It reads the instance data, in the following format:
    width
    n_circuits
    Wi, Hi for i in range(n_circuits)
    returns a tuple as (width, List of Wi, List of Hi)
    """
    # print(f)
    file = open(f)
    w = int(file.readline())
    # print("width ", width)
    n_piece = int(file.readline())
    W, H = [], []
    for i in range(n_piece):
        piece = file.readline()
        split_piece = piece.strip().split(" ")
        W.append((int(split_piece[0])))
        H.append((int(split_piece[1])))
    # print(pieces)
    return w, W, H


def show_shape(s, title, n_circuits):
    """
    create a image with s as image and title as title of the graph
    :param s:
    :param title:
    :param n_circuits:
    :return:
    """
    s = cv2.merge([s])
    img = plt.imshow(s)

    values, counts = np.unique(s, return_counts=True)
    # print(counts)
    colors = [img.cmap(img.norm(value)) for value in values]
    labels = []
    starting = 0
    if n_circuits + 1 == len(counts):
        starting = 1
        labels.append("Background")
    for i in range(starting, len(counts)):
        labels.append(f"Piece {i + 1}")
    patches = [mpatches.Patch(color=colors[i], label=labels[i]) for i in range(len(counts))]
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
    # plt.grid(b=True)
    # plt.savefig(f"{title}")

    plt.show()


def draw_solution(sol_shape, pieces):
    """
    Returns an array with shape = sol_shape, and pieces drawn in the array
    """
    arr = np.zeros(sol_shape)
    count = 1
    # area = 0
    for x_t, y_t, x, y in pieces:
        arr[x:x + x_t, y:y + y_t] = abs(count) * (250 / len(pieces))
        count += 1
        # print(arr)
        # print(area)
    arr = arr / np.max(arr)
    return np.rot90(arr)


def draw_solution_rot(sol_shape, pieces):
    """
    Returns an array with shape = sol_shape, and pieces drawn in the array
    """
    arr = np.zeros(sol_shape)
    count = 1
    # area = 0
    for x_t, y_t, x, y,rot in pieces:
        if rot == 0:
            arr[x:x + x_t, y:y + y_t] = abs(count) * (255 / len(pieces))
        else:
            arr[x:x + y_t, y:y + x_t] = abs(count) * (255 / len(pieces))
        count += 1
    arr = arr / np.max(arr)
    return np.rot90(arr)

def dims_sol_unify(W, H, X, Y):
    """
    It creates a list of tuple, where each tuple is composed by
    (Wi,Hi,Xi,Yi)
    :param W: width of the piece i
    :param H: height of the piece i
    :param X: X component of the piece i
    :param Y: Y component of the piece i
    :return:
    """
    return [(W[i], H[i], X[i], Y[i]) for i in range(len(W))]

def dims_sol_unify_rot(W, H, X, Y, rot):
    """
    It creates a list of tuple, where each tuple is composed by
    (Wi,Hi,Xi,Yi,roti)
    :param W: width of the piece i
    :param H: height of the piece i
    :param X: X component of the piece i
    :param Y: Y component of the piece i
    :param rot: rotation indicator of the piece i
    :return:
    """
    return [(W[i], H[i], X[i], Y[i], rot[i]) for i in range(len(W))]


def flatten(t):
    """
    Given a list of lists, it returns a flatten version of all lists
    :param t:
    :return:
    """
    return [item for sublist in t for item in sublist]


def save_sol(file_name, w, h, W, H, X, Y):
    """
    Save the solution in file file_name
    :param file_name: path to the file
    :param w: width of the solution
    :param h: height of the solution
    :param W: width of the piece i
    :param H: height of the piece i
    :param X: X component of the piece i
    :param Y: Y component of the piece i
    :return:
    """
    file = open(file_name, mode="w")
    file.write(f"{w} {h}\n")
    file.write(f"{len(X)}\n")
    for i in range(len(W)):
        file.write(f"{W[i]} {H[i]} {X[i]} {Y[i]}\n")
    file.close()

def save_sol_rot(file_name, w, h, W, H, X, Y, rot):
    """
    Save the solution in file file_name
    :param file_name: path to the file
    :param w: width of the solution
    :param h: height of the solution
    :param W: width of the piece i
    :param H: height of the piece i
    :param X: X component of the piece i
    :param Y: Y component of the piece i
    :return:
    """
    file = open(file_name, mode="w")
    file.write(f"{w} {h}\n")
    file.write(f"{len(X)}\n")
    for i in range(len(W)):
        file.write(f"{W[i]} {H[i]} {X[i]} {Y[i]} {rot[i]}\n")
    file.close()
