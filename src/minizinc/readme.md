# How to get same results

For Minizinc models, you should use the script we created (to do so, you need to add Minizinc Command line tool into the environment variable PATH ), because in the script we set some parameters like solver to use, timelimit, randomseed.
To execute the script, you have to use the following command line: 

```
python model_executor.py model_file.mzn
```  

This will execute the model_file.mzn with all dzn files present in the current working directory.

```
python model_executor.py model_file.mzn folder 
```  

This will execute the model_file.mzn with the all datafile indicated by the second path.

Otherwise you can use the solver configuration file, but notice that solving an instance in the Minizinc IDE is evidently slower than solving the same instance by using the script, this difference is caused by the Minizinc Command line tools and the IDE version. 