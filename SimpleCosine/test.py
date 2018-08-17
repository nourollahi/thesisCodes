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
import sys


tokenize = lambda doc: doc.lower().split(" ")


all_documents=list()
docs_for_doc_term_matrix=list()
 
striiing = sys.argv[1]
print striiing

#har doc dar 1 line ghrar darad
with open(sys.argv[1],'r') as openfileobject:
    for line in openfileobject:
	all_documents.append(line)
# print all_documents[0]






from sklearn.feature_extraction.text import TfidfVectorizer



# sklearn_tf = TfidfVectorizer(norm=None,min_df=0, use_idf =False,smooth_idf=False, sublinear_tf=False, tokenizer=tokenize)# this parameter set calculat TF
sklearn_tfidf = TfidfVectorizer(norm='l2',min_df=0, use_idf=True, smooth_idf=False, sublinear_tf=True, tokenizer=tokenize) # this parameter set caculate TF.IDF

TF_IDF = sklearn_tfidf.fit_transform(all_documents)
# TF = sklearn_tf.fit_transform(all_documents)

# print TF[0]
# print TF_IDF[0]
# print ("cosine similarity between doc0 and doc1= %s")%cosine_similarity(TF_IDF)[0][2]


max_similarity = 0.0
for num in range(len(all_documents)):
	for i in range(0,num):
    	  if cosine_similarity(TF_IDF)[num][i]>max_similarity:
 		  max_similarity = cosine_similarity(TF_IDF)[num][i]
    print num,max_similarity
    max_similarity=0



# myfile=open('toy-tfidf.txt','w')
# mmwrite(myfile, TF_IDF, comment='', field=None, precision=None, symmetry=None)
# myfile.close()

# myfile=open('toy-tf.txt','w')
# mmwrite(myfile, TF, comment='', field=None, precision=None, symmetry=None)
# myfile.close()

# featureNames=sklearn_tfidf.get_feature_names();
# myfile=open('toy-terms.txt','w')
# myfile.write("%s"%featureNames+"\n")
# for x in featureNames:
#     myfile.write(x.encode("utf-8")+"\n")
# myfile.close()



