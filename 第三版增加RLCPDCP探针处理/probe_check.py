import os, codecs
import re
from os.path import join, getsize

'''
#读取指定目录下的C文件，同时将处理的文件记录，用于比对是否漏文件或者多文件
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
'''
#从配置文件中读取需要处理的文件，对于配置了却无法打开的文件进行处理
filedir = 'D:\ViewRoot\chengengyu_view_ltea'
filelist = []
try:
    fileconfig = open('filename.txt', 'r')
    for line in fileconfig:
        line = line.strip()
        filelist.append(filedir + line)
    fileconfig.close
except:
    print('缺少文件目录的配置文件\n')


#遍历所有的文件，查找探针行
probe_list = []
pdcp_probe_list = []
probe_logs = []
probe_check_result = open('probe_check_result.txt','w')
for file in filelist:
    try:
        fp = codecs.open(file,'rb')
        for num,eachline in enumerate(fp):         
            try:
                #尝试用 gbk解码
                eachline = eachline.decode('gbk')
                if re.search(r'MAC_ADD_PROBE', eachline):
                    probe_logs.append(eachline)
                    #尝试辨析被注掉的探针
                    if re.search(r'/\*.*MAC_ADD_PROBE.*\*/', eachline):
                        probe_check_result.write("异常内容:" + eachline)
                    if re.search(r'//.*MAC_ADD_PROBE.*', eachline):
                        probe_check_result.write("异常内容:" + eachline)
                    eachline = eachline.replace(' ', '')
                    regex = re.compile(r'MAC_ADD_PROBE\((.+)\)')
                    for data in regex.findall(eachline):
                        try:
                            #部分探针为16进制
                            if re.search('0x|0X', data):
                                probe_num = int(data, 16)
                            else:
                                probe_num = int(data)
                            probe_list.append(probe_num)
                        except:
                            probe_check_result.write("异常内容:" + data + '\n')
                elif re.search(r'L2_ADD_PROBE', eachline):
                    probe_logs.append(eachline)
                    #尝试辨析被注掉的探针
                    if re.search(r'/\*.*L2_ADD_PROBE.*\*/', eachline):
                        probe_check_result.write("异常内容:" + eachline)
                    if re.search(r'//.*L2_ADD_PROBE.*', eachline):
                        probe_check_result.write("异常内容:" + eachline)
                    eachline = eachline.replace(' ', '')
                    regex = re.compile(r'L2_ADD_PROBE\((.+)\)')
                    for data in regex.findall(eachline):
                        try:
                            #部分探针为16进制
                            if re.search('0x|0X', data):
                                probe_num = int(data, 16)
                            else:
                                probe_num = int(data)
                            pdcp_probe_list.append(probe_num)
                        except:
                            probe_check_result.write("异常内容:" + data + '\n')
            except:
                #解析失败，通常是因为一些汉字的半角全角有问题
                err = "无法解析的行: 文件为" + file + "行号为:" + str(num+1) + '\n'
                probe_check_result.write(err)
                #print(num+1, eachline)
        fp.close
    except:
        err = '无法打开文件' + file +'\n'
        probe_check_result.write(err)



#将所有原始的探针行输出必要时比对使用
probe_file = open('probe_log.txt','w')
for line in probe_logs:
    probe_file.write(line)
probe_file.close


#将提取出的探针查重
probe_list.sort()
pdcp_probe_list.sort()
probe_check_result.write('MAC重复探针如下：\n')
for i in range(len(probe_list)-1):
    if probe_list[i] == probe_list[i+1]:
        probe_check_result.write(str(probe_list[i]) + '\n')
probe_check_result.write('PDCP RLC重复探针如下：\n')       
for i in range(len(pdcp_probe_list)-1):
    if pdcp_probe_list[i] == pdcp_probe_list[i+1]:
        probe_check_result.write(str(hex(pdcp_probe_list[i])) + '\n')

probe_check_result.write('正常处理结束')
probe_check_result.close

print('all done')
os.system('pause')

