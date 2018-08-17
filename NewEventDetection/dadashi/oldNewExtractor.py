from __future__ import division
import re
from sklearn.metrics.pairwise import cosine_similarity
import sys
import numpy as np
tokenize = lambda doc: doc.lower().split(" ")

requested_doc = list()
with open('agency-id-comment.txt','r') as openfileobject:
    for line in openfileobject:
                line = line.split('-')
                requested_doc.append(line[0]+"-"+line[1])
openfileobject.close()


with open('event-1-allText.txt','r') as openfileobject:
    for line in openfileobject:
                line = line.split('\t')
                if (line[1]+'-'+line[2] in requested_doc):
                        print (line[0]+'\t'+line[1]+'\t'+line[2]+'\t'+line[3]+'\t'+line[4]+'\t'+line[5]+'\t'+line[6]+'\t'+line[7]+'\t'+line[8]+'\t'+line[9]+'\t'+line[10]+'\t'+line[11]+'\t'+line[12]+'\t'+line[13])
		
openfileobject.close()
