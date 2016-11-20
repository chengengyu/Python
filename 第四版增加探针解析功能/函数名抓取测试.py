import os, codecs
import re
from os.path import join, getsize

probe_list = []
file = open('mac_access.c','r')
funclog = open('funclog.txt','w')
for num, line in enumerate(file):
    linetemp = line.strip()
    if re.search(r'^(?:void|s32|OSP_STATUS|u32|u8|u16|s8|s16) +\S+\s*\(.*\)', linetemp):
        if not re.search(r';|extern', linetemp):
            func_name = line
    linetemp = linetemp.replace(' ', '')
    result = re.search(r'MAC_ADD_PROBE\((.+)\)', linetemp)
    if result:
        #部分探针为16进制
        if re.search('0x|0X', result.group(1)):
            probe_num = int(result.group(1), 16)
        else:
            probe_num = int(result.group(1))
        log = (probe_num, str(num + 1) + ',' + func_name)
        probe_list.append(log)
funclog.close
file.close

#probe_list.sort()
file = open('probeConfig.cfg','w')
for line in probe_list:
    file.write(str(line[0]) + ';' + str(line[1]))
file.close
