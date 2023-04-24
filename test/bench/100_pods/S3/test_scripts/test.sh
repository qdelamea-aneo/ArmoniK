#!/bin/bash

#lunch runs with the same nb pods
# warm up run
#./bench_10k.sh

#clearmeasured runs
#for i in {1..3}
#do
#    ./bench_10k.sh >> 10k.json
#done
#/bench_1k.sh >> ../stats/100p/1k.json && ./bench_5k.sh >> ../stats/100p/5k.json && ./bench_10k.sh >> ../stats/100p/10k.json && ./bench_100k.sh >> ../stats/100p/100k.json
./bench_100k.sh >> ../stats/100p/100k.json
#clean the output file
#../python_scripts/cleaner.py

#print the test stats and plot graphs
#../python_scripts/wjson.py
