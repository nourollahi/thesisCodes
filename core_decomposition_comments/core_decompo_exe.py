import sys
from itertools import groupby
import subprocess
import os
def Cores(my_argus):
    # max_core = list()
    FNULL = open(os.devnull, 'w')    #use this if you want to suppress output to stdout from the subprocess
    args = "cores.exe pcore " + my_argus+" 12 0"
    subprocess.call(args, stderr=FNULL, shell=False)
    # print "Max Core Nodes:"
    coreValue = list()
    coreVertix = list()
    outputFileName = my_argus.split(".")
    file = open(outputFileName[0]+".vec",'r')
    line=file.readline()
    nodeCount=line.split(" ")[1]
    for i in range(0,int(nodeCount)):
        coreValue.append(float(file.readline().rstrip()))
    maxcoreValue= max(coreValue)
    # print maxcoreValue
    file.close()
    file = open(my_argus,'r')
    file.readline()
    for i in range(0,int(nodeCount)):
        coreVertix.append((file.readline().split(" ")[1]))
    file.close()
    vertex_value = zip(coreVertix, coreValue)

    # mac_core_index = [i for i, j in enumerate(coreValue) if j == maxcoreValue]
    # for i in mac_core_index:
    #     # print coreVertix[i]
    #     max_core.append(coreVertix[i])

    os.remove(outputFileName[0]+".clu")
    os.remove(outputFileName[0] + ".vec")
    return vertex_value








