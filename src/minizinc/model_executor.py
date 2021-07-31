import os
from os import popen as cmd
import sys
import time

"""
Usage: 
    python model_executor.py model_file.mzn
        this will execute the model_file.mzn with all dzn files present in the current working directory.
    
    python model_executor.py model_file.mzn data_file.dzn
        this will execute the model_file.mzn with the data file indicated. 
"""


def save_result(file_name, res_content):
    """
    given the file name f and the result of the model with f as data file, this function saves the result out into
    file f with txt as extension. :param f: :param out: :return:
    """
    file_name = file_name.replace("dzn", "txt")
    file_name = file_name.replace("ins", "sol")
    file_name = file_name.replace("dzn", "txt")
    res_content = res_content.replace("-", "")
    res_content = res_content.replace("=", "")
    print(res_content)
    open_file = open(file_name, "w")
    open_file.write(res_content.strip())
    open_file.close()


def get_data_file(path):
    list_file = os.listdir(path)
    # print(path)
    list_file = [file for file in list_file if file.strip().endswith(".dzn")]
    if len(list_file) == 0:
        print("There are no dzn files in the current working directory!")
        exit(-1)
    return list_file


if __name__ == "__main__":
    data_path = "./"
    files = []
    if len(sys.argv) == 1:
        print("You should specify which model you want to run!")
        exit(-1)
    model_file = ""
    if len(sys.argv) == 2:
        model_file = sys.argv[1]
        if not model_file.strip().endswith("mzn"):
            print("The model file has the wrong extension!")
            exit(-1)
        files = get_data_file("./")

    if len(sys.argv) == 3:
        model_file = sys.argv[1]
        data_path = sys.argv[2]
        files = get_data_file(data_path)

    if not os.path.isdir("./sol"):
        os.mkdir("sol")
    if len(files) == 0:
        print("There are no data file indicated!")
        exit(-1)
    total_time = 0
    print("model file",model_file)
    for f in files:
        begin_time = time.time_ns()
        print(f)
        stream = cmd(f"minizinc {model_file} -d {data_path}/{f}")
        end_time = time.time_ns()
        total_time += end_time - begin_time
        out = stream.read()
        save_result("./sol/" + f, out)

    total_time = total_time / (10 ** 9)
    print(f"Time take to run {len(files)} instances: {total_time}s, averagely {total_time / len(files)} sec/file.")
