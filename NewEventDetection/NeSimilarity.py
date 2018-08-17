from __future__ import division
import re
from sklearn.metrics.pairwise import cosine_similarity
import sys
import numpy as np
tokenize = lambda doc: doc.lower().split(" ")



khabar = list()
publish_time = list()
docs_for_doc_term_matrix=list()

iii=0
patt = re.compile('(\s*)\n(\s*)')
with open('event1-NER.txt','r') as openfileobject:
    for line in openfileobject:
		all_documents=list()
		line = patt.sub('', line)
		x=re.split(';',line)
		for i in range(8,len(x)-1):
			term_tag = re.split('\t',x[i])
			if "O" not in term_tag[1]:
				#term ro b y sb ezafe kon
				all_documents.append(term_tag[0])
		#all_documents.append(sb)
		NE_line = str(all_documents)
		khabar.append(' '.join(all_documents))
		#print khabar[iii]
		iii=iii+1
from sklearn.feature_extraction.text import TfidfVectorizer



sklearn_tfidf = TfidfVectorizer(norm='l2',min_df=0, use_idf=True, smooth_idf=False, sublinear_tf=True, tokenizer=tokenize) # this parameter set caculate TF.IDF
# # sklearn_tf = TfidfVectorizer(norm=None,min_df=0, use_idf =False,smooth_idf=False, sublinear_tf=False, tokenizer=tokenize)# this parameter set calculat TF
# # TF_IDF = sklearn_tfidf.fit_transform(all_documents)
# # sklearn_tfidf = TfidfVectorizer(norm=None, min_df=0, use_idf=True, smooth_idf=False, sublinear_tf=False, tokenizer = tokenize) #IDF
TF_IDF = sklearn_tfidf.fit_transform(khabar)

max_similarity = 0.0
max_index = 0
time_diff = 0
for num in range(len(khabar)):
#for num in range(0):
   for i in range(0,num):
   	  if cosine_similarity(TF_IDF)[num][i]>max_similarity:
		  max_similarity = cosine_similarity(TF_IDF)[num][i]
		  max_index = i
   print num,max_similarity
   max_similarity=0
