__author__ = 'chengengyu'

# from openpyxl import Workbook, load_workbook
from datetime import datetime
import numpy   # 配合Python3.4使用 numpy1.15版本

dateformat = "%Y-%m-%d %H:%M:%S"


class memberClass(object):
    def __init__(self, line):
        lineList = line.split(" ")
        self.name = lineList[0]  # 中文名
        self.id = lineList[1]    # 域用户名
        self.group = lineList[2]  # 资源组
        self.crNum = 0
        self.bugNum = 0
        self.tobeOpen = 0
        self.tobeModify = 0
        self.tobeResolve = 0
        self.tobeClose = 0
        self.close = 0
        self.bugModifyTimeSum = 0
        self.bugResolveTimeSum = 0
        self.bugCloseTimeSum = 0
        self.zc1Num = 0  # 内部版本研发自查
        self.zc1TobeCloseNum = 0
        self.zc2Num = 0  # 正式版本研发自查
        self.zc2OnwerNum = 0
        self.zc2TobeCloseNum = 0
        self.zc2ClosedNum = 0
        # self.zc2ModifyTimeSum = 0 部分研发自查未按流程流转，导致无modify时间
        self.zc2ResolveTimeSum = 0
        self.zc2CloseTimeSum = 0

    def count(self, bugInfo):
        if bugInfo.type == "设计变更" or bugInfo.type == "需求变更":
            self.crNum += 1
        if bugInfo.type == "缺陷":
            self.bugNum += 1
            if self.id == bugInfo.owner:
                if bugInfo.state == "已提出" or bugInfo.state == "已分配":
                    self.tobeOpen += 1
                if bugInfo.state == "已打开" and bugInfo.modifyFinishTime == "":
                    self.tobeModify += 1
                if bugInfo.state == "已打开" and bugInfo.modifyFinishTime != "":
                    self.tobeResolve += 1
                if bugInfo.state == "已解决":
                    self.tobeClose += 1
            if buginfo.state == "已关闭":
                if self.id == bugInfo.owner or self.id == bugInfo.Fixer:
                    self.Close += 1
                    self.bugModifyTimeSum += numpy.busday_count(bugInfo.submitTime.date(), bugInfo.modifyFinishTime.date())
                    self.bugResolveTimeSum += numpy.busday_count(bugInfo.submitTime.date(), bugInfo.resolveTime.date())
                    self.bugcloseTimeSum += numpy.busday_count(bugInfo.submitTime.date(), bugInfo.closeTime.date())
        if bugInfo.type == "研发自查":
            if bugInfo.detailVer.find("研发内部版本") != -1：
                if self.id = 
            else:



class groupClass(object):
    def __init__(self, groupName):
        self.group = groupName
        self.crNum = 0
        self.bugNum = 0
        self.tobeOpen = 0
        self.tobeModify = 0
        self.unModifyRatio = 0
        self.tobeResolve = 0
        self.tobeResolveRatio = 0
        self.tobeClose = 0
        self.tobeCloseRatio = 0
        self.close = 0
        self.closeRatio = 0
        self.bugModifyTimeSum = 0
        self.bugResolveTimeSum = 0
        self.bugCloseTimeSum = 0
        self.zc1Num = 0  # 内部版本研发自查
        self.zc1TobeCloseNum = 0
        self.zc1TobeCloseRatio = 0
        self.zc2Num = 0  # 正式版本研发自查
        self.zc2OnwerNum = 0
        self.zc2TobeCloseNum = 0
        self.zc2TobeCloseRatio = 0 
        self.zc2ClosedNum = 0
        self.zc2ClosedRation = 0
        self.zc2ResolveTimeSum = 0
        self.zc2CloseTimeSum = 0


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
            if self.assignTime.year == 1900:
                self.assignTime = ""
        self.modifyFinishTime = ""
        if lineList[6]:
            self.modifyFinishTime = datetime.strptime(lineList[6], dateformat)
            if self.modifyFinishTime.year == 1900:
                self.modifyFinishTime = ""
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
        self.detailVer = lineList[35]
        self.hlFlag = False
        self.valid = True
        self.assignDiff = ""
        self.modifyDiff = ""
        self.resolveDiff = ""
        self.closeDiff = ""

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
        if self.assignTime:
            self.assignDiff = numpy.busday_count(self.submitTime.date(), self.assignTime.date())
        if self.modifyFinishTime:
            self.modifyDiff = numpy.busday_count(self.submitTime.date(), self.modifyFinishTime.date())
        if self.resolveTime:
            self.resolveDiff = numpy.busday_count(self.submitTime.date(), self.resolveTime.date())
        if self.closeTime:
            self.closeDiff = numpy.busday_count(self.submitTime.date(), self.closeTime.date())


memberfp = open("K:\\work\\GitHub\\Python\\bugAnalyse\\member.txt", "r")
memberDic = {}
for num, eachLine in enumerate(memberfp):
    member = memberClass(eachLine.rstrip())
    memberDic[member.id] = member
memberfp.close()

# bugFileName = input("bug CSV: ")
bugfp = open("K:\\work\\GitHub\\Python\\bugAnalyse\\test.csv", "r")

bugCount = 0
bugVliadCount = 0

# 遍历所有bug，统计出属于HL的有效BUG
bugInfoList = []
for num, eachLine in enumerate(bugfp):
    try:
        bugInfo = BugInfoClass(eachLine)
        bugInfo.filter(memberDic)
        bugInfo.calcDiff()
        bugCount += 1
        if bugInfo.hlFlag is True and bugInfo.valid is True:
            bugInfoList.append(bugInfo)
            bugVliadCount += 1
        # print(bugInfo.BugNum)
        # print(bugInfo.fomrerState)
    except Exception as e:
        print(str(e))
        print(eachLine)

print(bugCount, bugVliadCount, len(bugInfoList))
bugfp.close()

# 按照规则统计到人、资源组、项目名下：
for bugInfo in bugInfoList:
    if bugInfo.owner in memberDic:
        memberDic[bugInfo.owner].count()




