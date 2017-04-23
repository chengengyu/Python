'''
1. chengengyu creat 2017/04/03

'''

import os
import codecs
import re
import xlwt
from os.path import join, getsize
import filecmp
import shutil

pathConfig = \
[\
    {\
    'ccDir': r'D:\\ViewRoot\\MP_HL_FDD\\EMB5216_HL_MP',\
    'gitDir': r'D:\\GitView\\GitTdd\\PUB-FDD',\
    'exception': r'\\TEST\\|\\CI\\|\\AP\\|\\RRM\\|\\RRC\\|\\CBB_BJ_DO\\|\\EMB5216_SSW\\|\\TDB36A_OSPV2\\'\
    },\
    {\
    'ccDir': r'D:\\ViewRoot\\MP_HL_FDD\\EMB5216_HL_MP\\AP',\
    'gitDir': r'D:\\GitView\\GitTdd\\AP-FDD',\
    'exception': r'\\TEST\\|\\CI\\'\
    },\
    {\
    'ccDir': r'D:\\ViewRoot\\MP_HL_FDD\\EMB5216_HL_MP\\RRC',\
    'gitDir': r'D:\\GitView\\GitTdd\\RRC-FDD',\
    'exception': r'\\TEST\\|\\CI\\'\
    },\
    {\
    'ccDir': r'D:\\ViewRoot\\MP_HL_FDD\\EMB5216_HL_MP\\RRM',\
    'gitDir': r'D:\\GitView\\GitTdd\\RRM-FDD',\
    'exception': r'\\TEST\\|\\CI\\'\
    }\
]

gitCommand = r'git --git-dir={dir}\\.git --work-tree={dir}\\ status'

def findFiles(fileDir, filterRe):
    fileDic = {}
    for root, dirs, files in os.walk(fileDir):
        if files:
            for name in files:
                if re.search('\.(c|h)$', name) and not re.search(filterRe, root):
                    if name in fileDic:
                        print('重复文件：'+ root + name + '\n')
                        print(fileDic[name]+ '\n')
                        continue
                    fileDic[name] =  join(root, name)
    return fileDic

def getStatus(fileDir):
    return os.popen(gitCommand.format(dir=fileDir)).read()

log = open('log2.txt', 'w')


gitStatus = ''

for config in pathConfig:
    logerr = ''
    ccDir = config['ccDir']
    gitDir = config['gitDir'] 
    log.write('\n当前view为：\n')
    log.write('CC路径：' + ccDir + '\n')
    log.write('git路径：' + gitDir + '\n')
    fileDicCc = findFiles(ccDir, config['exception'])
    fileDicGit = findFiles(gitDir, config['exception'])
    fileListDiff = []
    fileListFail = []
    for key in fileDicCc:
        if key in fileDicGit:
            if not filecmp.cmp(fileDicGit[key], fileDicCc[key]):
                fileListDiff.append(key)
        else:
            fileListFail.append(key)
            logerr += '此文件只存在于cc，git不存在，请手动入库：' + key + '\n'
    for file in fileListDiff:
        shutil.copy(fileDicCc[file], fileDicGit[file])
        if not filecmp.cmp(fileDicGit[file], fileDicCc[file]):
            fileListFail.append(file)
    gitStatus = getStatus(gitDir)
    log.write('\n当前状态\n' + gitStatus)
    log.write('\n差异文件一共' + str(len(fileListDiff)) + '个，如下：' + '\n')
    for file in fileListDiff:
        log.write(file + '\n')
    log.write('\n处理失败文件' + str(len(fileListFail)) + '个，如下：' + '\n')
    for file in fileListFail:
        log.write(file + '\n')
    log.write('\n错误异常如下：' + '\n')
    log.write(logerr)
    log.write('*************************************************************\n')



