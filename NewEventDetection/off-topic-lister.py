counter= 0
with open('event1-tag-computable-p2new.csv','r') as openfileobject:
    for line in openfileobject:
		line = line.split(',')
		#x=re.split('\t',line)
		#all_documents.append(x[7])
		if (line[3]=='off-topic'):
			print counter
		counter = counter+1;
