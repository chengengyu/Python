import os, codecs
import re
from os.path import join, getsize

def openfile():
    filedir = 'D:\ViewRoot\chengengyu_view_ltea\EMB5216_L2\EBP'
    filelist = []
    filename_file = open('probe_filename.txt','w')
    for root, dirs, files in os.walk(filedir):
        if files:
            for name in files:
                if re.search('.c$', name):
                    filelist.append(join(root, name))               
                    filename_file.write(name+'\n')
    filename_file.close
    return filelist

filelist = openfile()


print(filelist)
