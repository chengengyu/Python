import re

filenamelist = []
phase3file = open(r"D:\phase3.txt")	
for line in phase3file:
	filename = re.search(r'\\(.*)@@',line)
	filenamelist.append(filename.group(1))
#print(filenamelist)


filenamelist4 = []
phase4file = open(r"D:\phase4.txt")	
for line in phase4file:
	filename = re.search(r'\\(.*)@@',line)
	filenamelist4.append(filename.group(1))
#print(filenamelist)

result = open(r'D:\result','w')
for each in filenamelist:
	if each in filenamelist4:
		result.write(each+"  in\n")
	else:
		result.write(each+"   out\n")
		
