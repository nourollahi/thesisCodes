from __future__ import division
import string
import math
import numpy as np
import re
from scipy.sparse import csr_matrix
from scipy import sparse
from  scipy.io import mmwrite
import sklearn
from sklearn.metrics.pairwise import cosine_similarity


tokenize = lambda doc: doc.lower().split(" ")


all_documents=list()
docs_for_doc_term_matrix=list()

#har doc dar 1 line ghrar darad
with open('event1.txt','r') as openfileobject:
    for line in openfileobject:
	x=re.split('\t',line)
	all_documents.append(x[7])
# print all_documents[0]

from sklearn.feature_extraction.text import TfidfVectorizer
# sklearn_tf = TfidfVectorizer(norm=None,min_df=0, use_idf =False,smooth_idf=False, sublinear_tf=False, tokenizer=tokenize)# this parameter set calculat TF
sklearn_tfidf = TfidfVectorizer(norm='l2',min_df=0, use_idf=True, smooth_idf=False, sublinear_tf=True, tokenizer=tokenize) # this parameter set caculate TF.IDF

TF_IDF = sklearn_tfidf.fit_transform(all_documents)
# TF = sklearn_tf.fit_transform(all_documents)
print "TF.IDF model created."
# print TF[0]
featureNames=sklearn_tfidf.get_feature_names();
print '%s = %d' % ("vocab size", len(featureNames))

keywordss = list()
mat_TF_IDF = TF_IDF.todense()
for docId in len(all_documents):
	doc_vector = mat_TF_IDF[docId]
	arr = np.array(doc_vector)
	keywordss.append(arr[0].argsort()[-25:][::-1]

print keywordss
#arr =  np.array(doc_0_vector)
#print arr[0]
#print arr[0].argsort()[-3:][::-1]



# tmp = sklearn_tfidf.vocabulary_
# print featureNames[10]
# for x in featureNames:
# 	print ("raw term is ",x)
# print ("cosine similarity between doc0 and doc1= %s")%cosine_similarity(TF_IDF)[0][2]

# print cosine_similarity(TF_IDF)[6][9]
# max_similarity = 0.0
# for num in range(len(all_documents)):  #to iterate between 10 to 20
#    for i in range(0,num):
#    	  if cosine_similarity(TF_IDF)[num][i]>max_similarity:
# 		  max_similarity = cosine_similarity(TF_IDF)[num][i]
#    print max_similarity
#    max_similarity = 0



