from __future__ import division
import re
from sklearn.metrics.pairwise import cosine_similarity


tokenize = lambda doc: doc.lower().split(" ")

all_documents=list()
docs_for_doc_term_matrix=list()

patt = re.compile('(\s*)\n(\s*)')
with open('event1.txt', 'r') as openfileobject:
    for line in openfileobject:
        line = patt.sub('', line)
        x = re.split('\t', line)
        all_documents.append(x[7])

from sklearn.feature_extraction.text import TfidfVectorizer

sklearn_tfidf = TfidfVectorizer(norm='l2', min_df=0, use_idf=True, smooth_idf=False, sublinear_tf=True, tokenizer = tokenize) # this parameterSet caculate TF.IDF

TF_IDF = sklearn_tfidf.fit_transform(all_documents)


print cosine_similarity(TF_IDF)[0][100]
myCosine = TF_IDF * TF_IDF.transpose()
print myCosine[0,100]



