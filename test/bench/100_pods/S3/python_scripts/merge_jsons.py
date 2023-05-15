#! /usr/bin/env python3

import json
import re
from jsonmerge import merge

result=[]
with open("/home/ykharouni/work/Benchmarking/ArmoniK/versions.tfvars.json","r") as versions:
    result.append(json.load(versions))
with open("test_env.json","r") as test_env:
    result.append(json.load(test_env))
with open("5k.json","r") as stats:
    result.append(json.load(stats))
print(result)
merged=merge(result[0],result[1])
merged=merge(merged,result[2])

result2=[]
with open("/home/ykharouni/work/Benchmarking/ArmoniK/versions.tfvars.json","r") as versions:
    result2.append(json.load(versions))
with open("test_env.json","r") as test_env:
    result2.append(json.load(test_env))
with open("5k.json","r") as stats:
    result2.append(json.load(stats))
print(result)
merged2=merge(result2[0],result2[1])
merged2=merge(merged2,result2[2])

with open("results.json","w") as r:
    #json.dump(result,r )
    dict_json=[merged,merged2]
    json.dump(dict_json,r)
#file = "5k.json"
#clean_file(file)
#file = "10k.json"
#clean_file(file)
# file = "100k.json"
# clean_file(file)
