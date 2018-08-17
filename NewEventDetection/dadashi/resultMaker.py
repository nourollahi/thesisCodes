import os
import re
import sys
import logging
import numpy as np
from sklearn.metrics import confusion_matrix
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

feature_index = 8
distance = True

target= 43.0
nontarget= 60.0
maxThetha = 5

trueLabel = list()
distanceValue = list()
with open('LabeledData.csv', 'r') as openfileobject:
    for line in openfileobject:
        line = line.split(',')
        trueLabel.append(line[tag_index])
        distanceValue.append((line[feature_index].replace("\n","")))
openfileobject.close()
del distanceValue[0]
del trueLabel[0]
ourLable = list()
theta = 0.0
sumOfError = {}
costDetection = {}
if (distance):
    while theta < maxThetha:
        for doc in distanceValue:
            if float(doc)<theta:
                ourLable.append("old")
            else:
                ourLable.append("new")
        matrix = confusion_matrix(trueLabel, ourLable).ravel()
        tp = matrix[0]
        fp = matrix[2]
        fn = matrix [1]
        tn = matrix [3]
        sumOfError[str(theta)] = fp+fn
        costDetection[str(theta)] = ((fn/target)*0.02) +(0.1*(fp/nontarget)*0.98)
        ourLable = []
        theta+=0.001
    soe_min = min(sumOfError.keys(), key=(lambda k: sumOfError[k]))
    cost_min = min(costDetection.keys(), key=(lambda k: costDetection[k]))
else:
    while theta < maxThetha:
        for doc in distanceValue:
            if float(doc) < theta:
                ourLable.append("new")
            else:
                ourLable.append("old")
        matrix = confusion_matrix(trueLabel, ourLable).ravel()
        tp = matrix[0]
        fp = matrix[2]
        fn = matrix[1]
        tn = matrix[3]
        sumOfError[str(theta)] = fp + fn
        costDetection[str(theta)] = ((fn / target) * 0.02) + (0.1 * (fp / nontarget) * 0.98)
        ourLable = []
        theta += 0.001
    soe_min = min(sumOfError.keys(), key=(lambda k: sumOfError[k]))
    cost_min = min(costDetection.keys(), key=(lambda k: costDetection[k]))
print('# min error : ',sumOfError[soe_min])
print('cost min: ',costDetection[cost_min])
print ('# min error threshold: ',soe_min)
print ('min cost threshold: ',cost_min)
print "done"
