# -*- coding: utf-8 -*-
import re
import codecs
from itertools import groupby
from sklearn.feature_extraction.text import TfidfVectorizer
import networkx as nx
from core_decompo_exe import Cores
from os import listdir
from os.path import isfile, join
from sklearn.metrics import confusion_matrix

tokenize = lambda doc: doc.lower().split(" ")
sklearn_tf = TfidfVectorizer(norm=None,min_df=0, use_idf =False,smooth_idf=False, sublinear_tf=False, tokenizer=tokenize)
outputFileCount=0


def id_tag_def():
    global openfileobject, line, x
    idList = list()
    tag = list()
    with open('tag-computable.csv', 'r') as openfileobject:
        for line in openfileobject:
            x = re.split(',', line)
            idList.append(int(x[0]))
            tag.append(x[4])
    id_tag = zip(idList, tag)
    return id_tag
    print "id_tag_def() Done!"





def khabarid_CommentList_def():
    global openfileobject, line, x, khabarId_commentList, key
    rowId = list()
    comment = list()
    with codecs.open('input3.txt', 'r', encoding='utf-8') as openfileobject:
        for line in openfileobject:
            x = re.split('\t', line)
            rowId.append(int(x[0].encode('ascii', 'ignore')))
            comment.append(x[3])
    khabarId_comment = zip(rowId, comment)
    khabarId_commentList = {}
    for key, group in groupby(khabarId_comment, lambda x: x[0]):
        commentList = list()
        for khabarId_comment in group:
            commentList.append(khabarId_comment[1])
        khabarId_commentList[key] = commentList
    print "khabarid_CommentList_def() Done!"


def graph_file_def():
    global key, outputFileCount, x
    # proceedID = list()
    for key in khabarId_commentList:
        print "list in khabar----------------------------------------- ", key
        all_comments = khabarId_commentList[key]
        print "# of comments: ", len(all_comments)
        if len(all_comments) >= 2:
            # print all_comments
            outputFileCount = outputFileCount + 1
            TF = sklearn_tf.fit_transform(all_comments)
            nodes = sklearn_tf.get_feature_names()

            Gnx = nx.Graph()
            Gnx.add_nodes_from(nodes)

            # G = Graph()
            # G.add_vertices(nodes)

            # for i in range(len(nodes)):
            #     index[nodes[i].encode(encoding='utf-8')] = i
            #     G.add_vertices(str(i))

            # add index for terms. this is very behtar
            # print index['10']
            # G = Graph()
            # G.add_vertices(nodes)
            for current_doc in all_comments:
                # print current_doc
                splited = current_doc.split()
                if len(splited) > 2:
                    weight = float(1.0 / ((len(splited)) - 1))
                    for x in range(0, len(splited)):
                        for y in range(x + 1, len(splited)):
                            # term_x=str(index[splited[x].encode(encoding='utf-8')])
                            # term_y=str(index[splited[y].encode(encoding='utf-8')])
                            term_x = splited[x]
                            term_y = splited[y]

                            # temp_edge = G.get_eid(term_x, term_y, directed=False, error=False)

                            # if (temp_edge == -1 and (not(Gnx.get_edge_data(splited[x],splited[y])))) :
                            if ((not (Gnx.get_edge_data(splited[x], splited[y])))):
                                # if (temp_edge == -1) :
                                #     G.add_edge(term_x, term_y, weight=weight)

                                Gnx.add_edge(term_x, term_y, weight=weight)
                            else:
                                # new_weight = G.es[G.get_eid(term_x, term_y, error=False)]['weight']+weight
                                # G.delete_edges(G.get_eid(term_x,term_y))
                                # G.add_edge(term_x, term_y, weight=new_weight)

                                temp = Gnx[term_x][term_y]
                                new_weight = temp['weight'] + weight
                                Gnx.add_edge(term_x, term_y, weight=new_weight)
            # print G
            # G.write_pajek("netfiles/"+(str(key)+"-igraph.net"))
            nx.write_pajek(Gnx, "netfiles/" + (str(key)))
            # proceedID.append(key)
            # return proceedID
    print "graph_file_def() Done and # of Writed File is ", outputFileCount

def get_file_names():
    onlyfiles = [f for f in listdir("netfiles/") if isfile(join("netfiles/", f))]
    return onlyfiles

if __name__ == "__main__":
    D=10
    P=3
    theta=0.2
    desicion = dict()
    # khabarid_CommentList_def()
    # graph_file_def()
    avilable_files = get_file_names()
    # print avilable_files
    id_tag = id_tag_def()
    max_core_dict = dict()
    on_topic_id = list()
    for id in id_tag:
        current_id = id[0]
        current_tag = id[1]
        tempList = list()
        if ((current_tag !='off-topic') and (current_tag!='tahlil')):
            if (str(current_id) in avilable_files):
                print "procecing ID="+str(current_id)
                on_topic_id.append(current_id)
                tempList = Cores(("netfiles/" + str(current_id)))
            else:
                tempList = {}
            max_core_dict[current_id] = tempList
    # print len(on_topic_id)
    for i in on_topic_id:
        # print "i in on_topic_id ",i
        max_core = list()
        # print max_core_dict[162897]
        temp_cores= max_core_dict[int(i)]
        # print temp_cores
        # print zip(*temp_cores)
        core_vertix = zip(*temp_cores)[0]
        # print core_vertix[0]
        core_value = zip(*temp_cores)[1]
        maxcoreValue = max(core_value)
        mac_core_index = [ii for ii, jj in enumerate(core_value) if jj == maxcoreValue]
        for iii in mac_core_index:
            max_core.append(core_vertix[iii])
        if (D>len(max_core)):
            end = len(max_core)
        else:
            end = D
        left_sile = end*maxcoreValue
        top_words2 = list()
        for words in range(0,end):
            temp_word = max_core[0]
            top_words2.append(temp_word)
        right_side=0
        index = on_topic_id.index(i)
        # print index
        for iiii in range(0,P):
            pre_index=index-iiii-1
            if pre_index>=0:
                for jjj in range (0,end):
                    temp_vertix_value = max_core_dict[on_topic_id[pre_index]]
                    temp_cores2 = max_core_dict[int(i)]
                    # print temp_cores
                    # print zip(*temp_cores)
                    core_vertix2 = zip(*temp_cores2)[0]
                    # print core_vertix[0]
                    core_value2 = zip(*temp_cores2)[1]
                    for terms in top_words2:
                        if terms in core_vertix2:
                            temp_index = core_vertix2.index(terms)
                            right_side =right_side+ core_value2[temp_index]
                #do some thong calcultae rightes sigme and update right_sodi
        # print left_sile,"--",float(theta/(P+0.0))*right_side
        if left_sile>=float(theta/(P+0.0))*(right_side):
            desicion[i]="new"
        else:
            desicion[i] = "old"
    # print desicion
    true = dict()
    for id in id_tag:
        temp_id=id[0]
        temp_tag=id[1]
        # print temp_tag
        # print temp_id
        if temp_id in desicion:
            if temp_tag =='par-new':
                true[int(temp_id)]="new"
            else:
                true[int(temp_id)]=str(temp_tag)
    true_array = list()
    desicion_array = list()
    for key in true:
        true_array.append(true[key])
    for key in desicion:
        desicion_array.append(desicion[key])
    cf = confusion_matrix(true_array,desicion_array, labels=['new', 'old'])
    tn, fp, fn, tp = cf.ravel()
    p_miss=float(fn)/float(fn+tp)
    p_false_alarm = float(fp)/float(fp+tn)
    print ("p miss = "), p_miss
    print ("P false alarm = ") ,p_false_alarm
    print ("C_Det = "),(1*p_miss*0.02)+(0.1*p_false_alarm*0.98)
    print ("miss = "),fn
    print ("false alarm = "),fp

