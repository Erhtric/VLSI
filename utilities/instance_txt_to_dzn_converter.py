import sys
import os
import re


def read_text(f):
    file = open(f)
    width = int(file.readline())
    # print("width ", width)
    n_piece = int(file.readline())
    pieces = []
    for i in range(n_piece):
        piece = file.readline()
        split_piece = piece.strip().split(" ")
        pieces.append(int(split_piece[0]))
        pieces.append(int(split_piece[1]))
    # print(pieces)
    return width, pieces


def write_dzn(width, pieces, out_path="./file.dzn"):
    file = open(out_path, mode="w")
    file.write(f"width = {width};\n")
    file.write(f"n_pieces = {int(len(pieces) / 2)};\n")
    file.write(f"coords = [|")
    for i in range(len(pieces)):
        if i != len(pieces) - 1:
            file.write(f"{i},")
        else:
            file.write(f"{i}")
    file.write("|];")
    file.close()


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
            width, pieces = read_text(f)
            out_path = f.replace(".txt", ".dzn")
            # todo decide how to represent pieces in the model so, maybe, we want to change the input data format. 
            write_dzn(width, pieces, out_path)
