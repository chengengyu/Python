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
    'ccDir': r'D:\\ViewRoot\\MP_HL3\\EMB5216_HL_MP',\
    'gitDir': r'D:\\GitView\\GitEmtc\\PUB-FDD',\
    'exception': r'\\TEST\\|\\CI\\|\\AP\\|\\RRM\\|\\RRC\\|\\CBB_BJ_DO\\|\\EMB5216_SSW\\|\\TDB36A_OSPV2\\'\
    },\
    {\
    'ccDir': r'D:\\ViewRoot\\MP_HL3\\EMB5216_HL_MP\\AP',\
    'gitDir': r'D:\\GitView\\GitEmtc\\AP-FDD',\
    'exception': r'\\TEST\\|\\CI\\'\
    },\
    {\
    'ccDir': r'D:\\ViewRoot\\MP_HL3\\EMB5216_HL_MP\\RRC',\
    'gitDir': r'D:\\GitView\\GitEmtc\\RRC-FDD',\
    'exception': r'\\TEST\\|\\CI\\'\
    },\
    {\
    'ccDir': r'D:\\ViewRoot\\MP_HL3\\EMB5216_HL_MP\\RRM',\
    'gitDir': r'D:\\GitView\\GitEmtc\\RRM-FDD',\
    'exception': r'\\TEST\\|\\CI\\'\
    }\
]

successCC = 0
checkoutCommand = 'cleartool checkout -nc '
lsCoCommand = 'cleartool lsco -short -cview -rec '

makeBrachFlag = 1

def findFiles(filedir, filterRe):
    fileDic = {}
    for root, dirs, files in os.walk(filedir):
        if files:
            for name in files:
                if re.search('\.(c|h)$', name) and not re.search(filterRe, root):
                    if name in fileDic:
                        print('重复文件：'+  name + '\n')
                        continue
                    fileDic[name] =  join(root, name)
    return fileDic


def findCheckOut(fileDir):
    lsco = lsCoCommand + fileDir
    output = os.popen(lsco)
    return output.read()

def makeBrach(fileList):
    

log = open('log.txt', 'w')


checkoutFile = ''

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
    for key in fileDicGit:
        if key in fileDicCc:
            if not filecmp.cmp(fileDicGit[key], fileDicCc[key]):
                fileListDiff.append(key)
        else:
            fileListFail.append(key)
            logerr += '此文件只存在于git，cc不存在，请手动入库：' + key + '\n'
    if makeBrachFlag:
        makeBrach(fileListDiff)
    for file in fileListDiff:
        checkout = checkoutCommand + fileDicCc[file]
        if successCC != os.system(checkout):
            logerr += 'checkout 失败：' + file + '\n'
            fileListFail.append(file)
            continue
        shutil.copy(fileDicGit[file], fileDicCc[file])
        if not filecmp.cmp(fileDicGit[file], fileDicCc[file]):
            fileListFail.append(file)
    checkoutFile += findCheckOut(ccDir)

    log.write('\n差异文件一共' + str(len(fileListDiff)) + '个，如下：' + '\n')
    for file in fileListDiff:
        log.write(file + '\n')
    log.write('\n处理失败文件' + str(len(fileListFail)) + '个，如下：' + '\n')
    for file in fileListFail:
        log.write(file + '\n')
    log.write('\n错误异常如下：' + '\n')
    log.write(logerr)
    log.write('*************************************************************\n')
    
fileNum = 0
fileNum = len(re.findall('\.(?:c|h)', checkoutFile))
log.write('\n当前的checktout文件' + str(fileNum) + '个，如下：' + '\n')
log.write(checkoutFile)
log.close()



