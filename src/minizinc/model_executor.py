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
    given the file name f and the result of the model with ins-f as data file, this function saves the result out into
    file f with txt as extension.
    :param file_name:
    :param res_content:
    :return: 
    """
    file_name = file_name.replace("dzn", "txt")
    file_name = file_name.replace("ins", "out")
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

    if not os.path.isdir("./out"):
        os.mkdir("out")
    if len(files) == 0:
        print("There are no data file indicated!")
        exit(-1)
    # files = [f"ins-{i}.dzn" for i in range(19,20)]
    models = [
        # "cp_model_1.0.0.mzn",
        # "cp_model_1.0.0_rotations.mzn",
        # "cp_model_1.0.0_rotations_sym.mzn",
        # "cp_model_1.0.0_sym.mzn",
        # "cp_model_1.3.0.mzn",
        # "cp_model_1.3.0_rotations.mzn",
        # "cp_model_1.3.0_rotations_sym.mzn",
        "cp_model_1.3.0_sym.mzn"
    ]
    for model_file in models:
        time_file_name = model_file.replace("mzn", "json")
        with open(f"./{time_file_name}", "r") as f:
            time_json = json.load(f)

        total_time = 0
        print("model file", model_file)
        time_limit = 300 * 1000
        solver_name = "Chuffed"
        # files = [f"ins-{ins_n}.dzn" for ins_n in range(10,20)]
        for f in files:
            begin_time = time.time_ns()
            print(f)
            stream = cmd(f"minizinc {model_file} --solver {solver_name} -d {data_path}/{f}"
                         f" --solver-time-limit {time_limit} --random-seed 10")
            try:
                out = stream.readlines()
                end_time = time.time_ns()
                total_time += (end_time - begin_time)
                time_json[f] = (end_time - begin_time) / (10 ** 9)
                save_result("./out/" + f, out)
            except KeyboardInterrupt:
                print("Time limit reached!")
                time_json[f] = -1

        total_time = total_time / (10 ** 9)
        print(f"Time take to run {len(files)} instances: {total_time}s, averagely {total_time / len(files)} sec/file.")
        with open(f"./{time_file_name}", "w") as outfile:
            data = json.dumps(time_json, indent=4, sort_keys=True)
            outfile.write(data)
