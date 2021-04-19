__author__ = 'chengengyu'

# from openpyxl import Workbook, load_workbook
from datetime import datetime
import numpy   # 配合Python3.4使用 numpy1.15版本

dateformat = "%Y-%m-%d %H:%M:%S"

titleListBug = [
    "DTMUC",
    "简述",
    "提出时间",
    "状态",
    "等级",
    "分配时间",
    "modifyFinish时间",
    "产品",
    "版本",
    "owner",
    "提出人",
    "实际解决人",
    "首要解决人",
    "类型",
    "置无效时间",
    "置重复时间",
    "解决时间",
    "挂起时间",
    "子系统",
    "formerState",
    "关闭时间",
    "详细版本",
    "责任人",
    "是否HL相关",
    "分配时长",
    "modify时长",
    "解决时长",
    "关闭时长"
]

titleListPerson = [
    "姓名",
    "域用户名",
    "资源组",
    "CR个数",
    "BUG个数",
    "待打开",
    "待modifyFinish",
    "待resolve",
    "待关闭",
    "已关闭",
    "平均modifyFinish时长",
    "平均resolve时长",
    "平均关闭时长",
    "内部版本研发自查提出个数",
    "内部版本研发自查待关闭个数",
    "正式版本研发自查提出个数",
    "正式版本研发自查待关闭个数",
    "正式版本研发自查关闭个数",
    "正式版本研发自查平均resolve时长",
    "正式版本研发自查平均关闭时长"
]

titleListGroup = [
    "组名/项目名",
    "CR个数",
    "BUG个数",
    "待modifyFinish比例",
    "待resolve比例",
    "待关闭比例",
    "已关闭比例",
    "平均modifyFinish时长",
    "平均resolve时长",
    "平均关闭时长",
    "内部版本研发自查提出个数",
    "内部版本研发自查待关闭比例",
    "正式版本研发自查提出个数",
    "正式版本研发自查待关闭比例",
    "正式版本研发自查平均resolve时长",
    "正式版本研发自查平均关闭时长"
]


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
        self.bugModifyTimeAverage = 0
        self.bugResolveTimeSum = 0
        self.bugResolveTimeAverage = 0
        self.bugCloseTimeSum = 0
        self.bugCloseTimeAverage = 0
        self.zc1Num = 0  # 内部版本研发自查提出个数
        self.zc1TobeCloseNum = 0
        self.zc2Num = 0  # 正式版本研发自查提出个数
        # self.zc2OnwerNum = 0
        self.zc2TobeCloseNum = 0
        self.zc2ClosedNum = 0
        # self.zc2ModifyTimeSum = 0 部分研发自查未按流程流转，导致无modify时间
        self.zc2ResolveTimeSum = 0
        self.zc2ResolveTimeAverage = 0
        self.zc2CloseTimeSum = 0
        self.zc2CloseTimeAverage = 0

    def calc(self):
        self.bugModifyTimeAverage = self.bugModifyTimeSum / self.close
        self.bugResolveTimeAverage = self.bugResolveTimeSum / self.close
        self.bugCloseTimeAverage = self.bugCloseTimeSum / self.close
        self.zc2ResolveTimeAverage = self.zc2ResolveTimeSum / self.zc2ClosedNum
        self.zc2CloseTimeAverage = self.zc2CloseTimeSum / self.zc2ClosedNum

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
        self.bugModifyTimeAverage = 0
        self.bugResolveTimeSum = 0
        self.bugResolveTimeAverage = 0
        self.bugCloseTimeSum = 0
        self.bugCloseTimeAverage = 0
        self.zc1Num = 0  # 内部版本研发自查提出个数
        self.zc1TobeCloseNum = 0
        self.zc1TobeCloseRatio = 0
        self.zc2Num = 0  # 正式版本研发自查提出个数
        self.zc2TobeCloseNum = 0
        self.zc2TobeCloseRatio = 0
        self.zc2ClosedNum = 0
        self.zc2ResolveTimeSum = 0
        self.zc2ResolveTimeAverage = 0
        self.zc2CloseTimeSum = 0
        self.zc2CloseTimeAverage = 0

    def calc(self):
        self.unModifyRatio = (self.tobeopen + self.tobeModify) / self.bugNum
        self.tobeResolveRatio = self.tobeResolve / self.bugNum
        self.tobeCloseRatio = self.tobeClose / self.bugNum
        self.closeRatio = self.close / self.bugNum
        self.bugModifyTimeAverage = self.bugModifyTimeSum / self.close
        self.bugResolveTimeAverage = self.bugResolveTimeSum / self.close
        self.bugCloseTimeAverage = self.bugCloseTimeSum / self.close
        self.zc1TobeCloseRatio = self.zc1TobeCloseNum / self.zc1Num
        self.zc2TobeCloseRatio = self.zc2TobeCloseNum / (self.zc2TobeCloseNum + self.zc2ClosedNum)
        self.zc2ResolveTimeAverage = self.zc2ResolveTimeSum / self.zc2ClosedNum
        self.zc2CloseTimeAverage = self.zc2CloseTimeSum / self.zc2ClosedNum


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
        self.submitter = lineList[12]
        self.fixer = lineList[13]
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
        self.hlName = ""
        self.valid = True
        self.assignDiff = ""
        self.modifyDiff = ""
        self.resolveDiff = ""
        self.closeDiff = ""

    def filter(self, memberDic):
        '''
            1、判断是否属于：依次判断实际解决人、owner为HL人员
            2、有效性：当前状态不属于无效的、重复的、已挂起、待信息补充，
                或者当前状态为关闭，之前的状态不为：重复的、无效的、待信息补充
        '''
        if self.fixer in memberDic:
            self.hlName = self.fixer
        if self.owner in memberDic:
            self.hlName = self.owner
        if self.state != "已关闭":
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

    def count(self, memberDic, groupDic, productDic):
        product = productDic[self.product]
        member = memberDic[self.hlName]
        group = groupDic[member.group]

        if self.submitter in memberDic:
            memberSubmit = memberDic[self.submitter]
            groupSubmit = groupDic[memberSubmit.group]

        if self.type == "设计变更" or self.type == "需求变更":
            member.crNum += 1
            group.crNum += 1
            product.crNum += 1
        if self.type == "缺陷":
            member.bugNum += 1
            group.bugNum += 1
            product.bugNum += 1
            if self.id == self.owner:
                if self.state == "已提出" or self.state == "已分配":
                    member.tobeOpen += 1
                    group.tobeOpen += 1
                    product.tobeOpen += 1
                if self.state == "已打开" and self.modifyFinishTime == "":
                    member.tobeModify += 1
                    group.tobeModify += 1
                    product.tobeModify += 1
                if self.state == "已打开" and self.modifyFinishTime != "":
                    member.tobeResolve += 1
                    group.tobeResolve += 1
                    product.tobeResolve += 1
                if self.state == "已解决":
                    member.tobeClose += 1
                    group.tobeClose += 1
                    product.tobeClose += 1
            if self.state == "已关闭":
                if self.id == self.Fixer:
                    member.Close += 1
                    group.Close += 1
                    product.Close += 1
                    member.bugModifyTimeSum += self.modifyDiff
                    member.bugResolveTimeSum += self.resolveDiff
                    member.bugcloseTimeSum += self.closeDiff
                    group.bugModifyTimeSum += self.modifyDiff
                    group.bugResolveTimeSum += self.resolveDiff
                    group.bugcloseTimeSum += self.closeDiff
                    product.bugModifyTimeSum += self.modifyDiff
                    product.bugResolveTimeSum += self.resolveDiff
                    product.bugcloseTimeSum += self.closeDiff
        if self.type == "研发自查":
            if self.detailVer.find("研发内部版本") != -1:
                if self.submitter in memberDic:
                    memberSubmit.zc1Num += 1
                    groupSubmit.zc1Num += 1
                    product.zc1Num += 1
                    if self.state != "已关闭":
                        memberSubmit.zc1TobeCloseNum += 1
                        groupSubmit.zc1TobeCloseNum += 1
                        product.zc1TobeCloseNum += 1
            else:
                if self.submitter in memberDic:
                    memberSubmit.zc2Num += 1
                    groupSubmit.zc2Num += 1
                    product.zc2Num += 1
                if self != "已关闭":
                    member.zc2TobeCloseNum += 1
                    group.zc2TobeCloseNum += 1
                    product.zc2TobeCloseNum += 1
                else:
                    if member.id == self.Fixer:
                        member.zc2ClosedNum += 1
                        group.zc2ClosedNum += 1
                        product.zc2ClosedNum += 1
                        member.zc2ResolveTimeSum += self.resolveDiff
                        member.zc2CloseTimeSum += self.closeDiff
                        group.zc2ResolveTimeSum += self.resolveDiff
                        group.zc2CloseTimeSum += self.closeDiff
                        product.zc2ResolveTimeSum += self.resolveDiff
                        product.zc2CloseTimeSum += self.closeDiff


memberfp = open("K:\\work\\GitHub\\Python\\bugAnalyse\\member.txt", "r")
memberDic = {}
gourpDic = {}
for num, eachLine in enumerate(memberfp):
    member = memberClass(eachLine.rstrip())
    memberDic[member.id] = member
    if member.group not in groupDic:
        gourpDic[member.group] = groupClass(member.group)
memberfp.close()

# bugFileName = input("bug CSV: ")
bugFp = open("K:\\work\\GitHub\\Python\\bugAnalyse\\test.csv", "r")

bugCount = 0
bugVliadCount = 0

# 遍历所有bug，统计出属于HL的有效BUG
bugInfoList = []
productDic = {}
for num, eachLine in enumerate(bugFp):
    try:
        bugInfo = BugInfoClass(eachLine)
        bugInfo.filter(memberDic)
        bugCount += 1
        if bugInfo.hlName != "" and bugInfo.valid is True:
            if bugInfo.product not in productDic:
                productDic[bugInfo.product] = groupClass(bugInfo.product)
            bugInfoList.append(bugInfo)
            bugInfo.calcDiff()
            bugInfo.count(memberDic, groupDic, productDic)  # 按照规则统计到人、资源组、项目名下
            bugVliadCount += 1
        # print(bugInfo.BugNum)
        # print(bugInfo.fomrerState)
    except Exception as e:
        print(str(e))
        print(eachLine)

print(bugCount, bugVliadCount, len(bugInfoList))
bugFp.close()


hlBugFp = open("bugInfo.csv")
for item in titleListBug:
    hlBugFp.write(item + ",")
hlBugFp.write("\n")

for bugInfo in bugInfoList:
    hlBugFp.write(bugInfo.BugNum + ",")
    hlBugFp.write(bugInfo.title + ",")
    hlBugFp.write(bugInfo.)

