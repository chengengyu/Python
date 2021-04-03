import os
import sys
import re
import string

diffCountDir = r'K:\\Users\\eling\\Downloads\\Diffcount\\diffcount\\diffcount.exe '
configs = \
[\
    {\
        'name' : r'test',\
        'srcDir': r'K:\\Users\\eling\\Downloads\\Diffcount\\diffcount\\test1\\',\
        'desDir': r'K:\\Users\\eling\\Downloads\\Diffcount\\diffcount\\test2\\',\
        'dirs': ['1', '2']\
    }\
]

arg = '--print-files-info > '
#arg = '--for-program-reading'

#LANG	ADD	MOD	DEL	A&M	BLK	CMT	NBNC	STATE	BASELINE FILE	TARGET FILE
#C	0	1	0	1	1	0	0	MOD	1.c	1.c

lineRe = r'C\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t(\d+)\t\w+\t(\w\.(?:c|h))\t(\w\.(?:c|h))'
filterRe = r'check'
cmString = ['module', 'add', 'mod', 'del', 'a&m', 'blk', 'cmt', 'nbnc']

class diffResult:
    def __init__(self, name):
        self.name = name
        self.dadd = 0
        self.dmod = 0
        self.ddel = 0
        self.dam = 0
        self.dblk = 0
        self.dcmt = 0
        self.dnbnc = 0
    def add(self, result):
       self.dadd += int(result.group(1))
       self.dmod += int(result.group(2))
       self.ddel += int(result.group(3))
       self.dam += int(result.group(4))
       self.dblk += int(result.group(5))
       self.dcmt += int(result.group(6))
       self.dnbnc += int(result.group(7))

outDir = os.getcwd()
diffArry = []
diffSum = diffResult('sum')
for config in configs:
    diff = diffResult(config['name'])
    diffArry.append(diff)
    for fileDir in config['dirs']:
        cmd = diffCountDir + config['srcDir'] + fileDir  + ' ' + config['desDir'] + fileDir + ' ' + arg + outDir +'\\' + fileDir + '.txt'
        #print(cmd)
        os.system(cmd)
        result = open(fileDir + '.txt')
        for line in result:
            #print(line)
            if re.search(filterRe, line):
                continue
            searchResult = re.search(lineRe, line)
            if searchResult:
                diff.add(searchResult)
                diffSum.add(searchResult)
diffArry.append(diffSum)

resultFile = open('result.txt', 'w')
for item in cmString:
    #print(item)
    resultFile.write('{0: >10}'.format(item))
resultFile.write('\n')
for diff in diffArry:
    resultFile.write('{0: >10}'.format(diff.name))
    resultFile.write('{0: >10}'.format(diff.dadd))
    resultFile.write('{0: >10}'.format(diff.dmod))
    resultFile.write('{0: >10}'.format(diff.ddel))
    resultFile.write('{0: >10}'.format(diff.dam))
    resultFile.write('{0: >10}'.format(diff.dblk))
    resultFile.write('{0: >10}'.format(diff.dcmt))
    resultFile.write('{0: >10}'.format(diff.dnbnc))
    resultFile.write('\n')




