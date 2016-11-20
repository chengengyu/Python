import os, codecs
import re
from os.path import join, getsize

file = open('log','r')
log_dic = {}
for line in file:
    text = re.split(r' ', line.strip(), 1)
    key = text[0]
    if key in log_dic:       
        log_dic[key] = log_dic[key] + 1
    else:
        log_dic[key]= 1
    
print(log_dic)
