import os, codecs
import re
from os.path import join, getsize


filedirrrm = r'D:\ViewRoot\MP_HL3\EMB5216_HL_MP\RRM'
filedirmsh = r'D:\ViewRoot\MP_HL3\EMB5216_HL_MP\MSH'
filedirdba = r'D:\ViewRoot\MP_HL3\EMB5216_HL_MP\DBA'

def findfiles(filedir):
    for root, dirs, files in os.walk(filedir):
        if files:
            for name in files:
                if re.search('.(h|c)$', name):
                    print(name )
                    filelist.append(join(root, name))               
                    filename_file.write(name+'\n')
    return

filelist = []
filename_file = open('filename.txt','w')
findfiles(filedirrrm)
findfiles(filedirmsh)
findfiles(filedirdba)

filename_file.close
