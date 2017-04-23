'''
1. chengengyu creat 2017/04/03
2. chengengyu merge cc2git and git2cc 2017/04/16

'''

import os
import codecs
import re
from os.path import join, getsize
import filecmp
import shutil

#路径配置
pathConfigHlFile = \
[\
    {\
    'ccDir': r'D:\\ViewRoot\\MP_HL3\\EMB5216_HL_MP',\
    'gitDir': r'D:\\GitView\\GitTdd\\PUB-FDD',\
    'exception': r'\\TEST\\|\\CI\\|\\AP\\|\\RRM\\|\\RRC\\|\\CBB_BJ_DO\\|\\EMB5216_SSW\\|\\TDB36A_OSPV2\\'\
    },\
    {\
    'ccDir': r'D:\\ViewRoot\\MP_HL3\\EMB5216_HL_MP\\AP',\
    'gitDir': r'D:\\GitView\\GitTdd\\AP-FDD',\
    'exception': r'\\TEST\\|\\CI\\'\
    },\
    {\
    'ccDir': r'D:\\ViewRoot\\MP_HL3\\EMB5216_HL_MP\\RRC',\
    'gitDir': r'D:\\GitView\\GitTdd\\RRC-FDD',\
    'exception': r'\\TEST\\|\\CI\\'\
    },\
    {\
    'ccDir': r'D:\\ViewRoot\\MP_HL3\\EMB5216_HL_MP\\RRM',\
    'gitDir': r'D:\\GitView\\GitTdd\\RRM-FDD',\
    'exception': r'\\TEST\\|\\CI\\'\
    }\
]

pathConfigCommFile = \
[\
    {\
    'ccDir': r'D:\\ViewRoot\\MP_HL3\\EMB5216_SSW',\
    'gitDir': r'D:\\GitView\\GitTdd\\PUB-FDD',\
    'exception': r'\\TEST\\|\\CI\\|\\AP\\|\\RRM\\|\\RRC\\|\\CBB_BJ_DO\\|\\EMB5216_HL_MP\\|\\TDB36A_OSPV2\\'\
    },\
]


#相关说明
cc2GitReadme = '''
请仔细阅读以下说明:
1.建议在同步前删掉CC需同步路径下所有文件，重新update view来获取文件，避免CC路径残存非当前版本文件
2.请核对配置路径，其中exception下的路径会被忽略，默认的过滤路径也建议不要修改，如test或者emb5216ssw下文件需要同步，建议手动来处理
3.同步后请查看当前路径下的log.txt文件来核对同步的文件，并查看是否有错误信息
4.同步过程只处理在git和cc上都存在的文件，如果有新增文件请手动处理，可通过log.txt来查看
'''

git2ccReadme = '''
请仔细阅读以下说明:
1.请确认GIT目录下代码已经更新到需要同步的分支
2.请核对配置路径，其中exception下的路径会被忽略，默认的过滤路径也建议不要修改，如test或者emb5216ssw下文件需要同步，建议手动来处理
3.同步后请查看当前路径下的log.txt文件来核对同步的文件，并查看是否有错误信息
4.同步过程只处理在git和cc上都存在的文件，如果有新增文件请手动处理，可通过log.txt来查看
5.如果CC上已经拉出分支，或者希望通过自己配置的更新规则来保证checkout的位置，请使用不拉分支模式：
    5.1 此模式下，会直接在对应文件上checkout，建议使用此更新规则同步CC VIEW，保证取在对应分支节点上 'element -file .../分支名/latest'
6.如果CC上未所有文件都已拉出分支，请使用拉分支模式：
    6.1 此模式下，会查看要同步的文件是否有对应分支，无对应分支则会基于配置的标签名来分支，并在对应分支checkout
    6.2 此模式下，在后续操作中需要输入{分支名}、{基线}，请确认已准备好后在继续
    6.3 此模式下，需要保证脚本在对应view的EMB5216_HL_MP路径下，否则无法拉出分支
'''

#git和CC相关命令
gitCommand = r'git --git-dir={dir}\\.git --work-tree={dir}\\ status'
successCC = 0
checkoutCommand = 'cleartool checkout -nc '
checkoutByBranchCommond = checkoutCommand + '-branch {branchName} '
lsCoCommand = 'cleartool lsco -cview -rec '
rmlableCommand = 'cleartool rmlable {lableName} '
findNoBranchFileCommand = 'cleartool find . –element \'lbtype({lableName}) && (!brtype({branchName}))\' –print'
mkbranchCommand = 'cleartool mkbranch -nco -nc {branchName} {pathName}@@\{baseLableName}'


#根据路径递归查找文件，并将文件名相同文件找出
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
                    fileDic[name] = join(root, name)
    return fileDic

#根据filelist写入log
def listWriteInLog(fileList, log, comment):
    log.write('\n' + comment + str(len(fileList)) + '个，如下：' + '\n')
    for file in fileList:
        log.write(file + '\n')

#运行git命令获知当前git状态
def getGitStatus(fileDir):
    return os.popen(gitCommand.format(dir=fileDir)).read()


#CC向GIT同步
def cc2Git(pathConfig):
    log = open('log_cc2git.txt', 'w')
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
        gitStatus = getGitStatus(gitDir)
        log.write('\n当前状态\n' + gitStatus)
        listWriteInLog(fileListDiff, log, '差异文件一共')
        listWriteInLog(fileListFail, log, '处理失败文件')
        log.write('\n错误异常如下：' + '\n')
        log.write(logerr)
        log.write('*************************************************************\n')


#运行CC命令显示当前check out的文件
def findCheckOut(fileDir):
    lsco = lsCoCommand + fileDir
    output = os.popen(lsco)
    return output.read()

#拉分支
def makeBrach(fileList, brName, baseName):
    fileListMkbrSucc = []
    fileListMkbrFail = []
    fileListHaveBr = []
    for file in fileList:
        mkbranchCommand.format(baselableName=baseName, pathName=fileList, branchName=brName)
        if successCC != os.system(mkbranchCommand):
            fileListMkbrFail.append(file)
        else:
            fileListMkbrSucc.append(file)
    return fileListMkbrSucc, fileListMkbrFail, fileListHaveBr

#git向CC同步
def git2CC(pathConfig, brName='', baseName=''):
    log = open('log_git2cc.txt', 'w')
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
        fileListMkbrSucc = []
        fileListMkbrFail = []
        fileListHaveBr = []
        for key in fileDicGit:
            if key in fileDicCc:
                if not filecmp.cmp(fileDicGit[key], fileDicCc[key]):
                    fileListDiff.append(key)
            else:
                fileListFail.append(key)
                logerr += '此文件只存在于git，cc不存在，请手动入库：' + key + '\n'
        cleartoolCommand = ''
        if type == 'mkbranch':
            result = makeBrach(fileListDiff, brName, baseName)
            fileListMkbrSucc = result[0]
            fileListMkbrFail = result[1]
            fileListHaveBr = result[2]
            cleartoolCommand = checkoutByBranchCommond.format(branchName=brName)
        else:
            cleartoolCommand = checkoutCommand
        for file in fileListDiff:
            checkout = cleartoolCommand + fileDicCc[file]
            if successCC != os.system(checkout):
                logerr += 'checkout 失败：' + file + '\n'
                fileListFail.append(file)
                continue
            shutil.copy(fileDicGit[file], fileDicCc[file])
            if not filecmp.cmp(fileDicGit[file], fileDicCc[file]):
                fileListFail.append(file)
        checkoutFile += findCheckOut(ccDir)
        listWriteInLog(fileListDiff, log, '差异文件一共')
        listWriteInLog(fileListFail, log, '处理失败文件')
        if type == 'mkbranch':
            listWriteInLog(fileListMkbrSucc, log, '拉分支成功文件一共')
            listWriteInLog(fileListMkbrFail, log, 'n拉分支失败文件一共')
            #log.write('\n分支已存在文件一共' + str(len(fileListHaveBr)) + '个，如下：' + '\n')
            #for file in fileListHaveBr:
                #log.write(file + '\n')
        log.write('\n错误异常如下：' + '\n')
        log.write(logerr)
        log.write('*************************************************************\n')

    fileNum = 0
    fileNum = len(re.findall('\.(?:c|h)', checkoutFile))
    log.write('\n当前的checktout文件' + str(fileNum) + '个，如下：' + '\n')
    log.write(checkoutFile)
    log.close()

#根据输入判断执行
def getMergeOrder():
    print('\n请输入指令: \n 1:cc向git同步 \n 2:git向cc同步')
    order = input()
    if order == '1':
        return 'cc2git'
    elif order == '2':
        return 'git2cc'
    else:
        print('输入有误请重新输入,返回根目录\n')
        getConfigOrder()

#执行同步主函数
def execSync():
    order = getMergeOrder()
    if 'cc2git' == order:
        print(cc2GitReadme)
        order = input('确认无误后请输入Y继续进行：')
        if order == 'Y':
            print('执行同步\n')
            cc2Git(pathConfigHlFile)
        else:
            print('输入错误\n')
            execSync()
    elif 'git2cc' == order:
        print(git2ccReadme)
        order = input('拉分支方式继续请输入A，不拉分支方式继续请输入B：')
        if order == 'A':
            brName = input('请输入分支名：')
            baseName = input('请输入基线名：')
            print('拉分支\n')
            git2CC(pathConfigHlFile, brName=brName, baseName=baseName)
        elif order == 'B':
            print('不拉分支\n')
            git2CC(pathConfigHlFile)
        else:
            print('输入错误\n')
            execSync()

#打印配置的路径
def printConfig(pathConfig):
    index = 0
    for config in pathConfig:
        index += 1
        print('当前路径配置'+ str(index) + '为：')
        print('  CC路径:' + config['ccDir'])
        print('  git路径:' + config['gitDir'])
        print('  过滤路径:' + config['exception'])

#公共头文件入库git
def commFileToGit():
    order = input('该模式只能从cc同步公共头文件到cc，输入A继续，其他则返回：')
    if 'A' == order:
        cc2Git(pathConfigCommFile)
    else:
        getConfigOrder()

#根据路径获得差异文件list
def getDiffFile(fileDicCc, fileDicGit):
    fileListDiff = []
    fileListOnlyInCc = []
    fileListOnlyInGit = []
    for key in fileDicGit:
        if key in fileDicCc:
            if not filecmp.cmp(fileDicGit[key], fileDicCc[key]):
                fileListDiff.append(key)
        else:
            fileListOnlyInGit.append(key)
    for key in fileDicCc:
        if key not in fileDicGit:
            fileListOnlyInCc.append(key)
    return fileListDiff, fileListOnlyInCc, fileListOnlyInGit


#比较路径下文件并写入log
def compareCcGit(configList):
    fileListDiff = []
    fileListOnlyInCc = []
    fileListOnlyInGit = []
    for config in configList:
        fileDicCc = findFiles(config['ccDir'], config['exception'])
        fileDicGit = findFiles(config['gitDir'], config['exception'])
        result = getDiffFile(fileDicCc, fileDicGit)
        fileListDiff += result[0]
        fileListOnlyInCc += result[1]
        fileListOnlyInGit += result[2]
    log = open('diffFile.txt', 'w')
    listWriteInLog(fileListDiff, log, '差异文件')
    listWriteInLog(fileListOnlyInCc, log, '只存在于CC的文件')
    listWriteInLog(fileListOnlyInGit, log, '只存在于GIT的文件')
    return

#处理分支选择
def getConfigOrder():
    print('\n请输入指令: \n 1:HL文件同步 \n 2:公共头文件入库git \n 3:获取差异文件列表')
    order = input()
    if order == '1':
        return 'hlFile'
    elif order == '2':
        return 'commFile'
    elif order == '3':
        return 'compare'
    else:
        print('输入有误请重新输入')
        getConfigOrder()

if __name__ == "__main__":
    order = getConfigOrder()
    if 'hlFile' == order:
        print('hl文件配置\n')
        printConfig(pathConfigHlFile)
        execSync()
    elif 'commFile' == order:
        print('公共文件配置\n')
        printConfig(pathConfigCommFile)
        commFileToGit()
    elif 'compare' == order:
        print('比较差异时会同时比较HL文件配置路径下文件和公共头文件路径下文件\n')
        configList = pathConfigHlFile + pathConfigCommFile
        printConfig(configList)
        compareCcGit(configList)
    else:
        print('输入错误\n')
        getConfigOrder()


