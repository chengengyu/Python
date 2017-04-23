'''
1. chengengyu creat in 2017/03/19
'''

import xlwt
import os, codecs
import re
from os.path import join, getsize

pathSrc = 'K:\work\GitHub\Python\遍历对比宏\src'
pathDes = 'K:\work\GitHub\Python\遍历对比宏\des'

macroRe = r'^#define +(\w+) +(.+)$'
macroReNull = r'^#define +(\w+)$'

class MacroCompareResult():
    def __init__(self, name, defSrc, defDes, diffFlag):
        self.macroName = name
        self.macroDefSrc = defSrc
        self.macroDefDes = defDes
        self.diffFlag = diffFlag

def findfiles(filedir):
    filelist = []
    filename_file = open('filename.txt','w')
    for root, dirs, files in os.walk(filedir):
        if files:
            for name in files:
                if re.search('.(h|c)$', name):
                    filelist.append(join(root, name))
                    filename_file.write(name+'\n')
    filename_file.close
    return filelist

#根据文件list遍历文件，并查找其中的macro
def getMacro(fileList, errLog):
    errLineFp = open(errLog, 'w')
    macroInsList = []
    macroDict = {}
    for file in fileList:
        try:
            fp = codecs.open(file, 'rb')
            for num, eachLine in enumerate(fp):
                try:
                    #尝试用GBK解码
                    eachLine = eachLine.decode('gbk')
                    #判断是否是宏
                    eachLine = eachLine.strip()
                    macroLine = re.search(macroRe, eachLine)
                    if macroLine:
                        macroDict[macroLine.group(1)] = macroLine.group(2)
                        continue
                    macroLine = re.search(macroReNull, eachLine)
                    if macroLine:
                        macroDict[macroLine.group(1)] = ""
                        continue
                except:
                    #解析失败，通常是因为一些汉字的半角全角有问题
                    err = "无法解析的行: 文件为" + file + "行号为:" + str(num+1) + '\n'
                    errLineFp.write(err)
            fp.close()
        except:
            err = '无法打开文件' + file +'\n'
            errLineFp.write(err)
    return macroDict

def getCompareResult(macroDictSrc, macroDictDes):
    resultList = []
    #遍历源文件中宏定义判断是否和目标文件宏定义一致
    for key in macroDictSrc.keys():
        defSrc = macroDictSrc[key]
        if key in macroDictDes:
            defDes = macroDictDes[key]
        else:
            defDes = "不存在"
        if defSrc != defDes:
            diffFlag = 1
        else:
            diffFlag = 0
        macroResultIns = MacroCompareResult(key, defSrc, defDes, diffFlag)
        resultList.append(macroResultIns)
    #遍历目标文件中宏定义，如果在源文件中不存在，也认为不相等
    for key in macroDictDes.keys():
        if key not in macroDictSrc:
            macroResultIns = MacroCompareResult(key, "不存在", macroDictDes[key], 1)
            resultList.append(macroResultIns)
    return resultList

errorLogSrc = 'err_lineSrc.txt'
errorLogDes = 'err_lineDes.txt'
fileListSrc = findfiles(pathSrc)
fileListDes = findfiles(pathDes)
macroDictSrc = getMacro(fileListSrc, errorLogSrc)
macroDictDes = getMacro(fileListDes, errorLogDes)
macroCompareList = getCompareResult(macroDictSrc, macroDictDes)


wb = xlwt.Workbook(encoding = 'utf-8')
sheet = wb.add_sheet(u'宏定义')
row = 0
sheet.write(row, 0, '宏')
sheet.write(row, 1, '取值Src')
sheet.write(row, 2, '取值Des')
sheet.write(row, 3, '不一致')
for num, macroResultIns in enumerate(macroCompareList):     
    row = num + 1
    sheet.write(row,0, macroResultIns.macroName)
    sheet.write(row,1, macroResultIns.macroDefSrc)
    sheet.write(row,2, macroResultIns.macroDefDes)
    sheet.write(row,3, macroResultIns.diffFlag)
wb.save('macro.xls')


