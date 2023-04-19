#! /usr/bin/env python3

import json
from pytimeparse import parse
import matplotlib.pyplot as plt
import numpy as np

# class test_case
class TestCase:
    nbtasks = []
    time = []
    exec_time = []
    sub_time = []
    retrv_time = []
    throughput = []
    d_parallel = []


#function to read file and stock the data in lists
def f_reader(file):
    with open(file) as my_bench_file:
        data= my_bench_file.read()
    case = TestCase
    runs = json.loads(data)

    for run in runs:
        if(run["nb_pods"]==100):
            case.nbtasks.append(run["TotalTasks"])
            case.time.append(float(parse(run["ElapsedTime"])))
            case.exec_time.append(float(parse(run["TasksExecutionTime"])))
            case.sub_time.append(float(parse(run["SubmissionTime"])))
            case.retrv_time.append(float(parse(run["ResultRetrievingTime"])))
            case.throughput.append(float(run["throughput"]))
            case.d_parallel.append(run["DegreeOfParallelism"])

    return case


if __name__ == "__main__":

######################################################################
#                      TREAT 10K TASKS 100 PODS                      #
######################################################################

    #open 10k tasks on 100 pods file
    file = '10k.json'

    #store the runs stats
    run_10k_100p = TestCase
    run_10k_100p=f_reader(file)

    #calculte the mean times of the runs
    mean_time_10k_100=np.mean(run_10k_100p.time)
    mean_exec_time_10k_100p=np.mean(run_10k_100p.exec_time)
    mean_sub_time_10k_100=np.mean(run_10k_100p.sub_time)
    mean_retrv_time_10k_100=np.mean(run_10k_100p.retrv_time)
    mean_throughput_10k_100=np.mean(run_10k_100p.throughput)

    #print the perf stats
    print('Degree of parallelism of retrieving time is : '+ str(run_10k_100p.d_parallel[0]))
    print('mean total time for treatement of 10K tasks on 100 pods is : '+ str(mean_time_10k_100) +' s')
    print('mean time of the execution of 10K tasks on 100 pods is : '+ str(mean_exec_time_10k_100p) +' s')
    print('mean time of the submission of 10K tasks on 100 pods is : '+ str(mean_sub_time_10k_100) +' s')
    print('mean time of the retrieving of 10K tasks on 100 pods is : '+ str(mean_retrv_time_10k_100) +' s')
    print('mean throughput for 10K tasks on 100 pods is : '+ str(mean_throughput_10k_100)+" tasks/s \n")
