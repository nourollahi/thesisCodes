from __future__ import division
import re
from sklearn.metrics.pairwise import cosine_similarity
import sys
import numpy as np
tokenize = lambda doc: doc.lower().split(" ")
#################################################################################################
#off_toppic_index_list = list()
#with open('terror-data\LebeledData.csv','r') as openfileobject:
#    for line in openfileobject:
#		line = line.split(',')
		#x=re.split('\t',line)
		#all_documents.append(x[7])
		#if (line[3]=='off-topic' or line[3]=='tahlil'):
		#	off_toppic_index_list.append(line[0])
#openfileobject.close()
all_documents=list()
khabargozari = list()
publish_time = list()
docs_for_doc_term_matrix=list()
khabarID = list()
#################################################################################################
patt = re.compile('(\s*)\n(\s*)')
with open('IranAir-data\OldNewPlain.txt','r') as openfileobject:
    for line in openfileobject:
		line = patt.sub('', line)
		x=re.split('\t',line)
		all_documents.append(x[4])
		khabargozari.append(x[1])
		khabarID.append(x[2])
		pubTimetmp = re.split('-',x[3])
		tmpYear = re.split('/',pubTimetmp[0])
		tmpTime = re.split(':',pubTimetmp[1])
		publish_time.append(tmpYear[0]+"-"+tmpYear[1]+"-"+tmpYear[2]+"-"+tmpTime[0]+"-"+tmpTime[1])

from sklearn.feature_extraction.text import TfidfVectorizer
#################################################################################################

sklearn_tfidf = TfidfVectorizer(norm='l2',min_df=0, use_idf=True, smooth_idf=False, sublinear_tf=True, tokenizer=tokenize) # this parameter set caculate TF.IDF
# # sklearn_tf = TfidfVectorizer(norm=None,min_df=0, use_idf =False,smooth_idf=False, sublinear_tf=False, tokenizer=tokenize)# this parameter set calculat TF
# # TF_IDF = sklearn_tfidf.fit_transform(all_documents)
# # sklearn_tfidf = TfidfVectorizer(norm=None, min_df=0, use_idf=True, smooth_idf=False, sublinear_tf=False, tokenizer = tokenize) #IDF
TF_IDF = sklearn_tfidf.fit_transform(all_documents)

my_cosine = TF_IDF * TF_IDF.transpose()
my_cosine = my_cosine.todense()

max_similarity = 0.0
max_index = 0
time_diff = 0
#################################################################################################
print "khabarID - tf_idf - agency_match - time_diff - most_similar_id - most_similar_row"
for num in range(1,len(all_documents)):
	#if khabarID[num] not in off_toppic_index_list:
	n2 = np.arange(num)
	b = my_cosine[num, n2]
	time_current = re.split('-',publish_time[num])
	time_current = map(int,time_current)
	max_similarity = np.amax(b)
	max_index = np.argmax(b)
	time_mostsimilar = re.split('-',publish_time[max_index])
	time_mostsimilar = map(int,time_mostsimilar)
	time_diff = ((time_current[0]-time_mostsimilar[0])*31540000)+((time_current[1])*2628000-time_mostsimilar[1]*2628000)+((time_current[2])*86400-time_mostsimilar[2]*86400)+((time_current[3])*3600-time_mostsimilar[3]*3600)+((time_current[4])*60-time_mostsimilar[4]*60)         
	print khabarID[num],max_similarity,('1' if  khabargozari[num]==khabargozari[max_index] else '0'),time_diff,khabarID[max_index],khabargozari[max_index],max_index
	max_similarity=0
	#else:
	#	print "off-topic"
