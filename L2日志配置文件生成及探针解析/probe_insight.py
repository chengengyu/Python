import os, codecs
import re
from os.path import join, getsize

logtype = input('输入日志类型（0 MAC，1 RLC）：')
if int(logtype) == 0:
    config_file = open('MacProbeConfig.cfg', 'U')
    print('载入MAC配置文件')
else:
    config_file = open('RlcProbeConfig.cfg', 'U')
    print('载入RLC配置文件')

log_dic = {}
for line in config_file:
    text = re.split(r';', line.strip(), 1)
    #print(text)
    key = int(text[0])
    if key in log_dic:       
        log_dic[key] = '重复探针: '+ log_dic[key] + text[1]
    else:
        log_dic[key]= text[1]
#print(log_dic.items())
config_file.close

filename = input('输入文件名：')
print('读取文件 %s' % filename)
try:
    probe_file = open(filename, 'r')  
except:
    print('无法打开此文件')
    os.system('pause')

probe_list = []
log = probe_file.read()
log = re.sub(r'\s', '', log)
for i in range(0, len(log) - len(log)%8, 8):
    #print(log[i:j])
    probe_list.append(log[i:i+8])
probe_file.close
#print(probe_list)

probe_file = open(filename + '.probe', 'w')
for line in probe_list:
    num = int(line, 16)
    #print(num)
    if num in log_dic:
        printline = str(line) + ';  ' + ('%-7s' % str(num)) +  str(log_dic[num]) + '\n'
    else:
        printline = str(line) + '; 无此探针\n'
    probe_file.write(printline)


print('处理完毕')
os.system('pause')
