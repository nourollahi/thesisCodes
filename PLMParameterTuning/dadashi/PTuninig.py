import os
import re
import sys
import logging
import numpy as np
from sklearn.metrics import confusion_matrix
import copy
tag_index = 2
# count_comment = 0
# TF_IDF cosine= 1
# khabarGozari_match = 2
# time_diff = 3
# NE_similarity = 4
# keyword_owerlap(0-25) = 5
# WMD (w2v: wiki.fa) = 6
# tag = 7
# WMD (w2v:my_news) = 8
# soft_cosine = 9

feature_index = 7
distance = False

target= 43.0
nontarget= 60.0
maxThetha = 1
parameter_1 = 0;
trueLabel = {}
distanceValue = list()
counter = 0
with open('LabeledData.csv', 'r') as openfileobject:
    for line in openfileobject:
        line = line.split(',')
        trueLabel[counter] = (line[tag_index])
        counter = counter + 1
        # distanceValue.append((line[feature_index].replace("\n","")))
openfileobject.close()
del trueLabel[0]
percentLessThanP1 = {}
arrays = {}
total_max = 0;
with open('output.txt', 'r') as openfileobject:
    for line in openfileobject:
        line = line.split('-')
        docID_ID = line[0].split(':')
        del line[0]
        del line[0]
        x = np.array(line)
        y = x.astype(np.double)
        _max = max(y)
        _min = min(y)
        if (_max>total_max):
            total_max = _max
        # print _max , _min
        # for i in range (0,len(y)):
        #     y[i] = (i-_min)/(_max-_min)
        # normalized = (y - min(y)) / (max(y) - min(y))
        # tmp =  sum(i >= parameter_1 for i in y)
        # percentLessThanP1[int(docID_ID[1])] = float(tmp)/(len(y))
        arrays[int(docID_ID[1])] = y
# print total_max
openfileobject.close()
# print percentLessThanP1
theta = 0.0
sumOfError = {}
costDetection = {}




while theta < maxThetha:
    while parameter_1 < total_max:
        ourLable = {}
        ourLableArray = list()
        trueLabelArray = list()
        for key in arrays:
            y = arrays[key]
            tmp = sum(i <= parameter_1 for i in y)
            percentLessThanP1[key] = float(tmp)/(len(y))
        for key in percentLessThanP1:
            if float(percentLessThanP1[key]) < theta:
                ourLable[key] = "old"
            else:
                ourLable[key]= "new"
        #yeksan kardan trueLabel and ourLable
        trueLabelWithoutDelete = copy.deepcopy(trueLabel)
        selectedKeys = list()
        for key in trueLabel:
            if key not in ourLable:
                selectedKeys.append(key)
        for key in selectedKeys:
            del trueLabel[key]
        # print ourLable
        # print trueLabel
        for key in ourLable:
            ourLableArray.append(ourLable[key])
        for key in trueLabel:
            trueLabelArray.append(trueLabel[key])
        # print ourLableArray
        # print trueLabelArray
        matrix = confusion_matrix(trueLabelArray, ourLableArray).ravel()

        tp = matrix[0]
        fp = matrix[2]
        fn = matrix[1]
        tn = matrix[3]
        for key in selectedKeys:
            if (trueLabelWithoutDelete[key] == "New"):
                tp+=1
            else:
                tn+=1
        sumOfError[str(theta),str(parameter_1)] = fp + fn
        # print int(fp)
        # print int(fn)
        costDetection[str(theta),str(parameter_1)] = ((fn / target) * 0.02) + (0.1 * (fp / nontarget) * 0.98)
        ourLable = {}
        parameter_1+= 0.01;
        # print parameter_1
        matrix = []
    parameter_1 = 0
    theta += 0.01
    print theta

soe_min = min(sumOfError.keys(), key=(lambda k: sumOfError[k]))
cost_min = min(costDetection.keys(), key=(lambda k: costDetection[k]))

print('# min error : ',sumOfError[soe_min])
print('cost min: ',costDetection[cost_min])
print ('# min error threshold: ',soe_min)
print ('min cost threshold: ',cost_min)
print "done"
