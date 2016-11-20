import os, codecs
import re
from os.path import join, getsize

'''
#读取指定目录下的C文件，同时将处理的文件记录，用于比对是否漏文件或者多文件
filedir = 'D:\ViewRoot\shangyongpingtai\EMB5216_L2\EBP'
filelist = []
filename_file = open('l2log_filename.txt','w')
for root, dirs, files in os.walk(filedir):
    if files:
        for name in files:
            if re.search('.c$', name):
                filelist.append(join(root, name))               
                filename_file.write(name+'\n')
filename_file.close
'''
#从配置文件中读取需要处理的文件，对于配置了却无法打开的文件进行处理
filedir = 'D:\ViewRoot\shangyongpingtai'
filelist = []
try:
    fileconfig = open('filename.txt', 'r')
    for line in fileconfig:
        line = line.strip()
        filelist.append(filedir + line)
    fileconfig.close
except:
    print('缺少文件目录的配置文件\n')


#遍历所有的文件，抓取L2日志行
logline = '';
log_list = []
l2log_check_result = open('l2log_check_result.txt','w')
for file in filelist:
    try:
        fp = codecs.open(file,'rb')
        for num,eachline in enumerate(fp):         
            try:
                #尝试用GBK解码
                eachline = eachline.decode('gbk')
                #判断是否是L2日志记录行
                if re.search(r'g_pFuncL2Log\[.+\]\(', eachline): 
                    logline = eachline.strip()
                #考虑可能多行的情况，将每一行串起来
                elif logline:
                    logline = logline + eachline.strip()
                #L2日志记录以 g_pFuncL2Log[]();的形成存在，如果读取完整则添加至list中，否则继续读取下一行。
                if re.search(r'g_pFuncL2Log\[.+\]\(.+\)\s*;', logline):
                    log_list.append(logline)
                    logline = ''
            except:
                #解析失败，通常是因为一些汉字的半角全角有问题
                err = "无法解析的行: 文件为" + file + "行号为:" + str(num+1) + '\n'
                l2log_check_result.write(err)
        fp.close
    except:
        err = '无法打开文件' + file +'\n'
        probe_check_result.write(err)

#调试使用，将提取的未解析的代码行存放在文件中
l2log_file = open('l2log_file.txt','w')        
for log in log_list:
    l2log_file.write(log+'\n')
l2log_file.close

#解析原始代码，提取日志号和日志解析方式，并以 （日志号， （日志号;日志解析方式））的元组格式存在在list中，
l2log_result_err = open('l2log_file_err.txt', 'w')
loglist = []
l2log_result_err.write('日志内容有误的如下:\n')
for line in log_list:
    result = re.search('/\*(.+)\*/\s*(\d+),', line)
    if result:
        temp = result.group(1)
        temp = temp.replace(';', ',')
        log = (int(result.group(2)), result.group(2) + ';' + temp + ';\n')
        loglist.append(log) 
    else:
        #不匹配的line进行文件输出
        l2log_result_err.write(line+'\n')

#根据日志号排序并输入
loglist_filted = []
loglist.sort()
l2log_result_befor_filter = open('l2log_file_before_filter.txt', 'w')
for log in loglist:
    l2log_result_befor_filter.write(log[1])
l2log_result_befor_filter.close

#查重，将重复的输出
l2log_result_err.write('日志号重复且日志内容不同的如下:\n')
for i in range(len(loglist)-1):
    #日志号相同但是解析好不同才认为是异常
    if loglist[i][0] == loglist[i+1][0]:
        if loglist[i][1] != loglist[i+1][1]:
            l2log_result_err.write(loglist[i][1])
    else:
        #将不重复的添加至list，因为向后比较，所以当两个日志号相同时，会将前者当做异常，后者当做正常的
        loglist_filted.append(loglist[i])

#将查重后的日志进行加工处理，并输出
l2log_result = open('l2log_file_final.txt', 'w')
for log in loglist_filted:
    #去掉一些不必要的符号，将一些ueid等书写统一
    log_sprit = re.sub(r'\(s8 \*\)|\(s8\*\)|\\n|"', '', log[1])
    log_sprit = re.sub(r'(u|U)e(i|I)d', 'u16UeIndex', log_sprit)
    log_sprit = re.sub(r',\s?;', ';', log_sprit)
    l2log_result.write(log_sprit)
l2log_result.write('8999;')
l2log_result_err.close
l2log_result.close

print('all done')
os.system('pause')

