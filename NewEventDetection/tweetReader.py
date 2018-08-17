with open('output_got.csv','r') as openfileobject:
    for line in openfileobject:
		line = line.split(',')
		#x=re.split('\t',line)
		#all_documents.append(x[7])
		date = line[1].split()
		print date[0]+','+date[1]+','+line[4]
openfileobject.close()