import os
from os import popen as cmd
import sys
import time
import json

"""
Usage: 
    python model_executor.py model_file.mzn
        this will execute the model_file.mzn with all dzn files present in the current working directory.
    
    python model_executor.py model_file.mzn folder
        this will execute the model_file.mzn with the all datafile indicated by the second path. 
"""


def save_result(file_name, res_content):
    """
    given the file name f and the result of the model with f as data file, this function saves the result out into
    file f with txt as extension.
    :param file_name:
    :param res_content:
    :return: 
    """
    file_name = file_name.replace("dzn", "txt")
    file_name = file_name.replace("ins", "sol")
    file_name = file_name.replace("dzn", "txt")
    # print(res_content)
    open_file = open(file_name, "w")
    for i in range(len(res_content) - 2):
        open_file.write(res_content[i].strip() + "\n")
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
    with open("./time.json", "r") as f:
        time_json = json.load(f)

    total_time = 0
    print("model file", model_file)
    time_limit = 300 * 1000
    solver_name = "Chuffed"
    ins_n = 20
    if ins_n < 10:
        files = [f"ins-0{ins_n}.dzn"]
    else:
        files = [f"ins-{ins_n}.dzn"]
    for f in files:
        begin_time = time.time_ns()
        print(f)
        stream = cmd(f"minizinc {model_file} --solver {solver_name} -d {data_path}/{f}"
                     f"  --solver-time-limit {time_limit} --random-seed 10")
        end_time = time.time_ns()
        total_time += (end_time - begin_time)
        time_json[f] = (end_time - begin_time)/ (10 ** 9)
        out = stream.readlines()
        save_result("./sol/" + f, out)

    total_time = total_time / (10 ** 9)
    print(f"Time take to run {len(files)} instances: {total_time}s, averagely {total_time / len(files)} sec/file.")
    with open("time.json", "w") as outfile:
        data = json.dumps(time_json, indent=4, sort_keys=True)
        outfile.write(data)
