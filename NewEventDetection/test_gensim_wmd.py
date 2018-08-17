import os
import re
import sys
import logging
import numpy as np
from nltk.corpus import stopwords
from gensim.models import KeyedVectors

stop_words = stopwords.words('persian')
all_documents=list()
khabarID = list()

off_toppic_index_list = list()
with open('event1-tag-computable-p2new.csv','r') as openfileobject:
    for line in openfileobject:
        line = line.split(',')
        if (line[3]=='off-topic' or line[3]=='tahlil'):
            off_toppic_index_list.append(line[0])
openfileobject.close()


patt = re.compile('(\s*)\n(\s*)')
with open('event1.txt','r') as openfileobject:
    for line in openfileobject:
		line = patt.sub('', line)
		x=re.split('\t',line)
		if str(x[0]) not in off_toppic_index_list:
			all_documents.append(str(x[1]))
			khabarID.append(x[0])

print "document loaded"

 
size = len (all_documents)
Matrix = [10000] * size
for i in range(size):
    Matrix[i] = [10000] * size

model = KeyedVectors.load_word2vec_format('news_vector.bin', binary=True)

print 'model loaded'

for i in range(0,len(all_documents)):
	doc_i = str(all_documents[i]).decode('utf-8')
	doc_i = doc_i.split()
	doc_i = [w for w in doc_i if w not in stop_words]
	for j in range (0,i):
		doc_j = str(all_documents[j]).decode('utf-8')
		doc_j = doc_j.split()
		doc_j = [w for w in doc_j if w not in stop_words]
		distance = model.wmdistance(doc_i, doc_j)
		Matrix[i][j] = distance
		#Matrix[i][j] = i+j
	b = Matrix[i]
	min_distance = np.amin(b)
	print str(i)+"\t"+str(khabarID[i])+"\t"+str(min_distance)
