from __future__ import division
import re
from sklearn.metrics.pairwise import cosine_similarity


tokenize = lambda doc: doc.lower().split(" ")

all_documents=list()
docs_for_doc_term_matrix=list()

patt = re.compile('(\s*)\n(\s*)')
with open('toy.txt', 'r') as openfileobject:
    for line in openfileobject:
        line = patt.sub('', line)
        all_documents.append(line)

from sklearn.feature_extraction.text import TfidfVectorizer

sklearn_tfidf = TfidfVectorizer(norm=None, min_df=0, use_idf=False, smooth_idf=False, sublinear_tf=False, tokenizer = tokenize) # this parameter set caculate TF.IDF

TF_IDF = sklearn_tfidf.fit_transform(all_documents)
print TF_IDF[0]
# print TF_IDF.idf_


#print cosine_similarity(TF_IDF)[2][1]
#print all_documents[2]

