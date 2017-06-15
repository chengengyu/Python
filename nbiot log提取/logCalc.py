'''
1. chengengyu creat 2017/05/29

'''

import os
import codecs
import re
from os.path import join, getsize
import shutil
import math
import xlwt

def getFileName(fileDir, fileName):
    result = re.search(r'.+\\(.+?)$', fileDir)
    if result:
        return result.group(1) + fileName
    else:
        return fileName

#根据路径递归查找文件，并将文件名相同文件找出
def findFiles(fileDir):
    fileList = []
    fileNamefp = open('fileName.txt', 'w')
    for root, dirs, files in os.walk(fileDir):
        if files:
            for name in files:
                if re.search('\.tra\.txt$', name):
                    fileList.append(name)
                    fileNamefp.write(name+'\n')
    fileNamefp.close
    return fileList

commonFile = 3

def funNull(itemList):
    return itemList

def calcThroughPut(itemList):
    itemList[commonFile] = int(itemList[commonFile]) * 4
    itemList[commonFile+1] = int(itemList[commonFile+1]) * 4
    return itemList

def calcCrc(itemList):
    if int(itemList[commonFile]) == 0:
        dlCrc = 0
    else:
        dlCrc = (1 - (int(itemList[commonFile+1]) / int(itemList[commonFile])))
    if int(itemList[commonFile+2]) == 0:
        ulCrc = 0
    else:
        ulCrc = (1 - (int(itemList[commonFile+3]) / int(itemList[commonFile+2])))
    itemList.append(dlCrc)
    itemList.append(ulCrc)
    return itemList

def calcRu(itemList):
    itemList.append(0)
    if int(itemList[commonFile+2]) == 1:
        itemList[commonFile+6] = int(itemList[commonFile+5])
    elif int(itemList[commonFile+2]) == 3:
        itemList[commonFile+6] = int(itemList[commonFile+5]) / int(itemList[commonFile+4]) * 4
    elif int(itemList[commonFile+2]) == 6:
        itemList[commonFile+6] = int(itemList[commonFile+5]) / int(itemList[commonFile+4]) * 2
    elif int(itemList[commonFile+2]) == 12:
        itemList[commonFile+6] = int(itemList[commonFile+5]) / int(itemList[commonFile+4]) * 1
    else:
        itemList[commonFile+5] = 'error'
    return itemList

def calcRsrp(itemList):
    itemList[commonFile+2] -= 141
    return itemList    


#DL: DCIN1, agglvl=2, cce=0, rep=1
#DL: PDSCH_CFG(429,2), bufferidx 0, newdataflag 1, rep 1, tti 3, mcs 12, tbsize 680, rnti 1261
#prach config,usCellId23,usSubframeOffset0,ucNInit5,ucNStart12,ucPreambleFormat0,usRepeatNum2
#NL1C_DL SNR 22, ServingRSRP 93, PCI 23
#NL1C_DL MIBSNR 21, MIBRSRP 93, PCI 23
#NL1C_UL: PUSCH CFG enable(109, 3): ucPuschFormat = 1, ucSubcarrierSpacing = 1, ucSubcarrierNum = 1, ucSubcarrierAllocIdx = 11, MCS index = 10, ucRepeatNum = 1, usTransLen = 32
#NL1C_UL: usTbSize = 616, ucRuNum = 4, RuLth(slotNum) = 16, NewTxFlag = 1
#[EMAC][0]           0,           0,           0,           0,           0,           0,           0  (备注第一个数字和第4个数字分别是上行和下行速率，2s统计，单位byte)
#NL1C DL Total: 2, CRC 2, TP(bits) 1360, ACK 2, New 3, UL Total 3, New 3, TP 376(bits)
#SYS: Set TX RF power 23  

timeRe = r'\d+ (0x\w+) (0x\w+) 0x\w+ 0x\w+ \w+ +'

configList = \
[\
    {\
    're': timeRe + r'DL: DCIN(\d), agglvl=(\d), cce=(\d), rep=(\d)',\
    'comment': ['file', 'sn', 'time', 'DICN', 'agglvl', 'cce', 'rep'],\
    'num': 6,\
    'fun': funNull,\
    'sheetName': 'npdcch'\
    },\
    {\
    're': timeRe + r'DL: PDSCH_CFG\(\d+,\d+\), bufferidx \d+, newdataflag (\d+), rep (\d+), tti (\d+), mcs (\d+), tbsize (\d+), rnti \d+',\
    'comment': ['file', 'sn', 'time', 'newdataflag', 'rep', 'tti', 'mcs', 'tbsize'],\
    'num': 7,\
    'fun': funNull,\
    'sheetName': 'npdsch'\
    },\
    {\
    're': timeRe + r'prach config,usCellId\d+,usSubframeOffset\d+,ucNInit\d+,ucNStart\d+,ucPreambleFormat(\d+),usRepeatNum(\d+)',\
    'comment': ['file', 'sn', 'time', 'Format', 'rep'],\
    'num': 4,\
    'fun': funNull,\
    'sheetName': 'nprach'\
    },\
    {\
    're': timeRe + r'NL1C_UL: PUSCH CFG enable\(\d+, \d+\): ucPuschFormat = (\d+), ucSubcarrierSpacing = (\d+), ucSubcarrierNum = (\d+), ucSubcarrierAllocIdx = \d+, (?:MCS|RES) index = (\d+), ucRepeatNum = (\d+), usTransLen = (\d+)',\
    'comment': ['file', 'sn', 'time', 'Format', 'SubcarrierSpacing', 'SubcarrierNum', 'MCS/RES', 'rep', 'transLen', 'ru'],\
    'num': 8,\
    'fun': calcRu,\
    'sheetName': 'npusch'\
    },\
    {\
    're': timeRe + r'NL1C_UL: usTbSize = (\d+), ucRuNum = (\d+), RuLth\(slotNum\) = (\d+), NewTxFlag = (\d+)',\
    'comment': ['file', 'sn', 'time', 'tbSize', 'ruNum', 'ruLth', 'NewTx'],\
    'num': 6,\
    'fun': funNull,\
    'sheetName': 'npusch_tb'\
    },\
    {\
    're': timeRe + r'NL1C_DL (MIB|)SNR (-?\d+), (?:Serving|MIB)RSRP (\d+), PCI (\d+)',\
    'comment': ['file', 'sn', 'time', 'type', 'snr', 'rsrp', 'pci'],\
    'num': 6,\
    'fun': calcRsrp,\
    'sheetName': 'snr'\
    },\
    {\
    're': timeRe + r'\[EMAC\]\[0\] +(\d+), +\d+, +\d+, +(\d+), +\d+, +\d+, +\d+',\
    'comment': ['file', 'sn', 'time', 'ul(bps)', 'dl(bps)'],\
    'num': 4,\
    'fun': calcThroughPut,\
    'sheetName': 'throughPut'\
    },\
    {\
    're': timeRe + r'NL1C DL Total: (\d+), CRC (\d+), TP\(bits\) \d+, ACK \d+, New \d+, UL Total (\d+), New (\d+), TP \d+\(bits\)',\
    'comment': ['file', 'sn', 'time', 'dl total', 'dl crc正确', 'ul total', 'ul new', 'dl误码率', 'ul误码率'],\
    'num': 6,\
    'fun': calcCrc,\
    'sheetName': 'crc'\
    },\
    {\
    're': timeRe + r'SYS: Set TX RF power (\d+)',\
    'comment': ['file', 'sn', 'time', 'TX RF power'],\
    'num': 3,\
    'fun': funNull,\
    'sheetName': 'UL POWER'\
    }\
]


class itemClass(object):
    def __init__(self, num ,serResult, fileName):
        self.itemList = []
        self.itemList.append(fileName)
        for i in range(1, num+1):
            if re.search(r'0x', serResult.group(i)):
                self.itemList.append(serResult.group(i))
            elif re.match(r'-?\d+', serResult.group(i)):
                self.itemList.append(int(serResult.group(i)))
            else:
                self.itemList.append(serResult.group(i))

class typeClass(object):
    def __init__(self, re, comment, num, fun, sheetName):
        self.serRe = re
        self.comment = comment
        self.itemNum = num
        self.calcFun = fun
        self.itemInsList = []
        self.sheetName = sheetName

def typeClassListInit():
    typeClassInsList = []
    for config in configList:
        typeIns = typeClass(config['re'], config['comment'], config['num'], config['fun'], config['sheetName'])
        typeClassInsList.append(typeIns)
    return typeClassInsList

def writeXls(typeClassInsList, fileName):
    wb = xlwt.Workbook(encoding = 'utf-8')
    for typeIns in typeClassInsList:
        sheet = wb.add_sheet(typeIns.sheetName)
        row = 0
        for colnum in range(len(typeIns.comment)):
            sheet.write(row, colnum, typeIns.comment[colnum])
        for num, eachitem in enumerate(typeIns.itemInsList):
            row = num + 1
            for colnum in range(len(eachitem.itemList)):
                sheet.write(row, colnum, eachitem.itemList[colnum])
    wb.save(fileName + '.xls')

def convertLog(fileDir):
    logErr = open('logErr.txt', 'w')
    fileList = findFiles(fileDir)
    typeClassInsList = typeClassListInit()
    for file in fileList:
        fp = open(fileDir + '\\' + file, 'r')
        # for line in fp:
        #     for typeIns in typeClassInsList:
        #         result = re.search(typeIns.serRe, line)
        #         if result:
        #             itemIns = itemClass(typeIns.itemNum, result, file)
        #             itemIns.itemList = typeIns.calcFun(itemIns.itemList)
        #             typeIns.itemInsList.append(itemIns)
        try:
            for line in fp:
                for typeIns in typeClassInsList:
                    result = re.search(typeIns.serRe, line)
                    if result:
                        itemIns = itemClass(typeIns.itemNum, result, file)
                        itemIns.itemList = typeIns.calcFun(itemIns.itemList)
                        typeIns.itemInsList.append(itemIns)
        except Exception as e:
            logErr.write(str(e))
            err = "无法解析的行: 文件为" + file + ":" + str(line) + '\n'
            logErr.write(err)
    fileName = getFileName(fileDir, 'logResult')
    writeXls(typeClassInsList, fileDir + '\\' + fileName)
    print('统计处理成功\n')

timeReFortime = r'\d+ 0x\w+ (0x\w+) 0x\w+ 0x\w+ \w+ +'
serviceRe = timeReFortime + r'.(CONTROL_PLANE_SERVICE_REQ|EMM_ATTACH_REQUEST)'
rrcReqRe = timeReFortime + r'.(rrcConnectionRequest-NB)'
preambleRe = timeReFortime + r'(Preamble start)'
rrcConRe = timeReFortime + r'.(rrcConnectionSetup-NB)'
rrcCompRe = timeReFortime + r'.(rrcConnectionSetupComplete-NB)'


timeConfigList = \
[\
    {\
    're': [serviceRe, rrcReqRe, preambleRe, rrcConRe, rrcCompRe],\
    'comment': ['文件', '事件', '原始时间', '时延', '时延2'],\
    'sheetName': 'serviceReq-rrcConComplete',\
    'stepMax': 5,\
    'dulpRe': preambleRe,\
    'diffIndexTh': 2\
    }\
]

'''
    {\
    're': [preambleRe, rrcConRe, rrcCompRe],\
    'comment': ['文件', '事件', '原始时间', '时延'],\
    'sheetName': 'preamble-rrcConComplete',\
    'stepMax': 3
    }\
'''

def timeDiff(timeStart, timeEnd):
    return (int(timeEnd, 16) - int(timeStart, 16)) / 16

def timeTypeClassListInit():
    timeTypeClassInsList = []
    for config in timeConfigList:
        timeTypeIns = timeTypeClass(config['re'], config['comment'], config['sheetName'], config['stepMax'], config['dulpRe'], config['diffIndexTh'])
        timeTypeClassInsList.append(timeTypeIns)
    return timeTypeClassInsList

class timeTypeClass(object):
    def __init__(self, reList, comment, sheetName, stepMax, dulpRe, diffIndexTh):
        self.reList = reList
        self.comment = comment
        self.sheetName = sheetName
        self.stepMax = stepMax
        self.dulpRe = dulpRe
        self.diffIndexTh = diffIndexTh
        self.step = 0
        self.timeInsList = []
    def getTime(self, file, line):
        start = re.search(self.reList[0], line)
        if start:
            itemIns = timeItemClass(file, start.group(2), start.group(1))
            self.timeInsList.append(itemIns)
            self.step = 1
        elif self.step < self.stepMax and self.step != 0:
            eventResult = re.search(self.reList[self.step], line)
            if eventResult:
                itemIns = self.timeInsList[-1]
                itemIns.append(eventResult.group(2), eventResult.group(1), self.diffIndexTh)
                self.step += 1
            else:
                duplicateResult = re.search(self.dulpRe, line)
                if duplicateResult:
                    itemIns = self.timeInsList[-1]
                    itemIns.append(duplicateResult.group(2), duplicateResult.group(1), self.diffIndexTh)

class timeItemClass(object):
    def __init__(self, file, event, time):
        self.fileName = file
        self.eventList = []
        self.timeList = []
        self.diffList = []
        self.diffList2 = []
        self.eventList.append(event)
        self.timeList.append(time)
        self.diffList.append(0)
        self.diffList2.append(0)

    def append(self, event, time, diffIndexTh):
        self.eventList.append(event)
        self.timeList.append(time)
        diff = timeDiff(self.timeList[0], self.timeList[-1])
        if len(self.timeList) <= diffIndexTh:
            diff2 = 0
        else:
            diff2 = timeDiff(self.timeList[diffIndexTh], self.timeList[-1])
        self.diffList.append(diff)
        self.diffList2.append(diff2)

def writeTimeXls(typeClassInsList, fileName):
    wb = xlwt.Workbook(encoding = 'utf-8')
    for typeIns in typeClassInsList:
        sheet = wb.add_sheet(typeIns.sheetName)
        row = 0
        for colnum in range(len(typeIns.comment)):
            sheet.write(row, colnum, typeIns.comment[colnum])
        for eachitem in typeIns.timeInsList:
            for num in range(len(eachitem.eventList)):
                row = row + 1
                sheet.write(row, 0, eachitem.fileName)
                sheet.write(row, 1, eachitem.eventList[num])
                sheet.write(row, 2, eachitem.timeList[num])
                sheet.write(row, 3, eachitem.diffList[num])
                sheet.write(row, 4, eachitem.diffList2[num])
    wb.save(fileName + '.xls')


def calcAccessTime(fileDir):
    logErr = open('logErrAccess.txt', 'w')
    fileList = findFiles(fileDir)
    timeTypeClassInsList = timeTypeClassListInit()
    for file in fileList:
        fp = open(fileDir + '\\' + file, 'r')
        try:
            for line in fp:
                for timeTypeIns in timeTypeClassInsList:
                    timeTypeIns.getTime(file, line)
        except Exception as e:
            logErr.write(str(e))
            err = "\n errLine: 文件为" + file + ":" + str(line) + '\n'
            logErr.write(err)
    fileName = getFileName(fileDir, 'TimeResult')
    writeTimeXls(timeTypeClassInsList, fileDir + '\\' + fileName)
    print('时延计算成功\n')


if __name__ == "__main__":
    while 1:
        fileDir = input('请输入路径:')
        #fileDir = r'E:\兰州外场\script\timeTest'
        convertLog(fileDir)
        calcAccessTime(fileDir)












