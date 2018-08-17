import os
import re
import sys
import logging
import numpy as np
from nltk.corpus import stopwords
from gensim.models import KeyedVectors
from gensim import corpora
from gensim.matutils import softcossim

stop_words = stopwords.words('persian')
all_documents = list()
khabarID = list()

off_toppic_index_list = list()
with open('event1-tag-computable-p2new.csv','r') as openfileobject:
    for line in openfileobject:
        line = line.split(',')
        if line[3] == 'off-topic' or line[3]=='tahlil':
            off_toppic_index_list.append(line[0])
openfileobject.close()


patt = re.compile('(\s*)\n(\s*)')
with open('event1.txt', 'r') as openfileobject:
    for line in openfileobject:
        line = patt.sub('', line)
        x = re.split('\t', line)
        if str(x[0]) not in off_toppic_index_list:
                all_documents.append(str(x[1]))
                khabarID.append(x[0])
openfileobject.close()
all_documents_stop_removed = list()

for doc in all_documents:
    currentDoc = str(doc).decode('utf-8')
    currentDoc = currentDoc.split()
    currentDoc = [w for w in currentDoc if w not in stop_words]
    all_documents_stop_removed.append(currentDoc)

all_documents = []
dictionary = corpora.Dictionary(all_documents_stop_removed)
corpus = [dictionary.doc2bow(document) for document in all_documents_stop_removed]

print "document loaded and corpus created."

 
size = len (all_documents_stop_removed)
Matrix = [0] * size
for i in range(size):
    Matrix[i] = [0] * size

model = KeyedVectors.load_word2vec_format('wiki.fa.vec', binary=False)
similarity_matrix = model.similarity_matrix(dictionary)

print 'model loaded'

for i in range(1,len(all_documents_stop_removed)):
    for j in range (0,i):
        # print i,",",j
        doc_i = all_documents_stop_removed[i]
        doc_j = all_documents_stop_removed[j]
        doc_i = dictionary.doc2bow(doc_i)
        doc_j = dictionary.doc2bow(doc_j)
        similarity = softcossim(doc_i, doc_j, similarity_matrix)
        # print similarity
        Matrix[i][j] = similarity
    b = Matrix[i]
    min_distance = np.amax(b)
    print str(i)+"\t"+str(khabarID[i])+"\t"+str(min_distance)
    # print i