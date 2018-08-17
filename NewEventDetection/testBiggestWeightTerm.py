from __future__ import division
import re
from sklearn.metrics.pairwise import cosine_similarity
import sys
import numpy as np
tokenize = lambda doc: doc.lower().split(" ")


all_documents=list()
docs_for_doc_term_matrix=list()

patt = re.compile('(\s*)\n(\s*)')
with open('event1.txt','r') as openfileobject:
    for line in openfileobject:
		line = patt.sub('', line)
		x=re.split('\t',line)
		all_documents.append(x[7])

from sklearn.feature_extraction.text import TfidfVectorizer



# sklearn_tf = TfidfVectorizer(norm=None,min_df=0, use_idf =False,smooth_idf=False, sublinear_tf=False, tokenizer=tokenize)# this parameter set calculat TF
sklearn_tfidf = TfidfVectorizer(norm='l2',min_df=0, use_idf=True, smooth_idf=False, sublinear_tf=True, tokenizer=tokenize) # this parameter set caculate TF.IDF
# sklearn_tf = TfidfVectorizer(norm=None,min_df=0, use_idf =False,smooth_idf=False, sublinear_tf=False, tokenizer=tokenize)# this parameter set calculat TF
# TF_IDF = sklearn_tfidf.fit_transform(all_documents)
# sklearn_tfidf = TfidfVectorizer(norm=None, min_df=0, use_idf=True, smooth_idf=False, sublinear_tf=False, tokenizer = tokenize) #IDF
TF_IDF = sklearn_tfidf.fit_transform(all_documents)


# max_similarity = 0.0
# for num in range(len(all_documents)):
#    for i in range(0,num):
#    	  if cosine_similarity(TF_IDF)[num][i]>max_similarity:
# 		  max_similarity = cosine_similarity(TF_IDF)[num][i]
#    print num,max_similarity
#    max_similarity=0
feature_names = sklearn_tfidf.get_feature_names()
doc = 0
feature_index = TF_IDF[doc,:].nonzero()[1]
tfidf_scores = zip(feature_index, [TF_IDF[doc, x] for x in feature_index])

for w, s in [(feature_names[i], s) for (i, s) in tfidf_scores]:
  print w, s

