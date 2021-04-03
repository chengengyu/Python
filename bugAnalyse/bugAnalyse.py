__author__ = 'chengengyu'

from openpyxl import Workbook, load_workbook
from datetime import datetime
import numpy   #配合Python3.4使用 numpy1.15版本



dateformat = "%Y-%m-%d %H:%M:%S"

class memberClass(object):
    def __init__(self, line):
        lineList = line.split(" ")
        self.name = lineList[0]
        self.id = lineList[1]
        self.group = lineList[2]


class BugInfoClass(object):
    def __init__(self, bugLine):
        lineList = bugLine.split(",")
        self.BugNum = lineList[0]
        self.title = lineList[1]
        self.submitTime = datetime.strptime(lineList[2], dateformat)
        self.state = lineList[3]
        self.rank = lineList[4]
        self.assignTime = ""
        if lineList[5]:
            self.assignTime = datetime.strptime(lineList[5], dateformat)
        self.modifyFinishTime = ""
        if lineList[6]:
            self.modifyFinishTime = datetime.strptime(lineList[6], dateformat)
        self.product = lineList[7]
        self.ver = lineList[8]
        self.owner = lineList[9]
        self.Fixer = lineList[13]
        self.firstFixer = lineList[14]
        self.type = lineList[21]
        self.invalidTime = ""
        if lineList[22]:
            self.invalidTime = datetime.strptime(lineList[22].split(".")[0], dateformat)
        self.duplicateTime = ""
        if lineList[23]:
            self.duplicateTime = datetime.strptime(lineList[23].split(".")[0], dateformat)
        self.resolveTime = ""
        if lineList[24]:
            self.resolveTime = datetime.strptime(lineList[24].split(".")[0], dateformat)
        self.postponeTime = ""
        if lineList[25]:
            self.postponeTime = datetime.strptime(lineList[25].split(".")[0], dateformat)
        self.subsystem = lineList[31]
        self.fomrerState = lineList[32]
        if lineList[33]:
            self.closeTime = datetime.strptime(lineList[33].split(".")[0], dateformat)
        self.hlFlag = False
        self.valid = True

    def filter(self, memberDic):
        ''' 
            1、判断是否属于：依次判断owner、实际解决人、首要解决人为HL人员。
            2、有效性：当前状态不属于无效的、重复的、已挂起、待信息补充，
                或者当前状态为关闭，之前的状态不为：重复的、无效的、待信息补充
        '''
        if self.owner in memberDic or self.Fixer in memberDic or self.firstFixer in memberDic:
            self.hlFlag = True
        if self.state == "已关闭":
            if self.state == "重复的" or self.state == "无效的" or self.state == "待信息补充" or self.state == "已挂起":
                self.valid = False
        else:
            if self.fomrerState == "重复的" or self.fomrerState == "无效的" or self.fomrerState == "待信息补充":
                self.valid = False
    
    def calcDiff(self):
        self.assignDiff = ""
        self.modifyDiff = ""
        self.resolveDiff = ""
        self.closeDiff = ""
        if self.assignTime:
            self.assignDiff = numpy.busday_count(self.submitTime.date(), self.assignTime.date())
            print(self.assignDiff, self.submitTime, self.assignTime)


memberfp = open("K:\\work\\GitHub\\Python\\bugAnalyse\\member.txt", "r")
memberDic = {}
for num, eachLine in enumerate(memberfp):
    member = memberClass(eachLine.rstrip())
    memberDic[member.id] = member 
memberfp.close()

#bugFileName = input("bug CSV: ")
bugfp = open("K:\\work\\GitHub\\Python\\bugAnalyse\\test.csv", "r")

bugCount = 0
bugVliadCount = 0

bugInfoList = []
for num, eachLine in enumerate(bugfp):
    try:
        bugInfo = BugInfoClass(eachLine)
        bugInfo.filter(memberDic)
        bugInfo.calcDiff()
        bugCount += 1
        if bugInfo.hlFlag == True and bugInfo.valid == True:
            bugInfoList.append(bugInfo)
            bugVliadCount += 1
        #print(bugInfo.BugNum)
        #print(bugInfo.fomrerState)
    except Exception as e:
        print(str(e))
        print(eachLine)

print(bugCount, bugVliadCount, len(bugInfoList))
bugfp.close()





