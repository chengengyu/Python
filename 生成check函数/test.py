import os, codecs
import re
from os.path import join, getsize

'''
def splitStructCode(fileDef):
    CodeList = []
    CodeList = re.findall(r'(?s)(typedef +struct\S*{[\d\D]} *[\w|_]+;)?', fileDef)
    print(CodeList)
    return


fileDef = open('def.txt','r')
fileDefStr = fileDef.read()
#print(fileDefStr)
#splitStructCode(fileDefStr)
CodeList = re.findall(r'(typedef +struct\s*{.+?} *[\w|_]+;)', fileDefStr, re.S)
for code in CodeList:
    struName = re.findall(r'}([\w|_]+);', code)
    print(struName)
    print("*******")
'''

def findfiles(filedir):
    filelist = []
    filename_file = open('filename.txt','w')
    for root, dirs, files in os.walk(filedir):
        if files:
            for name in files:
                if re.search('.py$', name):
                    filelist.append(join(root, name))               
                    filename_file.write(name+'\n')
    filename_file.close
    return filelist

findfiles(os.curdir)