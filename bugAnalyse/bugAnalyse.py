# __author__ = 'chengengyu'

# from openpyxl import Workbook, load_workbook
from datetime import datetime
import numpy   #计算工作日间隔使用

# dateformat = "%Y/%m/%d %H:%M:%S"
dateformat = "%Y/%m/%d"

# 根据提出时间统计大于某年份的BUG
YEAR_FILTER = 2021

# 研发自查提醒门限
ZC1_DIFF = 10
ZC2_DIFF = 20

TITLE_LIST_BUG = [
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

TITLE_LIST_MEMBER = [
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

TITLE_LIST_MEMBER_ZC = [
    "姓名",
    "内部版本研发自查待推动数（提出超过10天）",
    "正式版本研发自查待推动数（提出超过22天）"
]

TITLE_LIST_GROUP = [
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
        self.valid = int(lineList[3]) # 是否显示
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
        self.zc1TodoNum = 0 # 提出超过10工作日，未关闭
        self.zc2TodoNum = 0 # 提出超过20工作日，未关闭

    def calc(self):
        self.bugModifyTimeAverage = division(self.bugModifyTimeSum, self.close)
        self.bugResolveTimeAverage = division(self.bugResolveTimeSum, self.close)
        self.bugCloseTimeAverage = division(self.bugCloseTimeSum, self.close)
        self.zc2ResolveTimeAverage = division(self.zc2ResolveTimeSum, self.zc2ClosedNum)
        self.zc2CloseTimeAverage = division(self.zc2CloseTimeSum, self.zc2ClosedNum)

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
        self.unModifyRatio = division((self.tobeOpen + self.tobeModify) * 100, self.bugNum)
        self.tobeResolveRatio = division(self.tobeResolve * 100, self.bugNum)
        self.tobeCloseRatio = division(self.tobeClose * 100, self.bugNum)
        self.closeRatio = division(self.close * 100, self.bugNum)
        self.bugModifyTimeAverage = division(self.bugModifyTimeSum, self.close)
        self.bugResolveTimeAverage = division(self.bugResolveTimeSum, self.close)
        self.bugCloseTimeAverage = division(self.bugCloseTimeSum, self.close)
        self.zc1TobeCloseRatio = division(self.zc1TobeCloseNum * 100, self.zc1Num)
        self.zc2TobeCloseRatio = division(self.zc2TobeCloseNum * 100, self.zc2TobeCloseNum + self.zc2ClosedNum)
        self.zc2ResolveTimeAverage = division(self.zc2ResolveTimeSum, self.zc2ClosedNum)
        self.zc2CloseTimeAverage = division(self.zc2CloseTimeSum, self.zc2ClosedNum)


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
        self.formerState = lineList[32]
        self.closeTime = ""
        if lineList[33]:
            self.closeTime = datetime.strptime(lineList[33].split(".")[0], dateformat)
        self.detailVer = lineList[35].replace("\n", "").replace("\r", "")
        self.hlName = ""
        self.valid = True
        self.assignDiff = ""
        self.modifyDiff = ""
        self.resolveDiff = ""
        self.closeDiff = ""
        self.bugAlarmFlag = False
        self.zcTodoFlag = False # 内部版本或者正式版本研发自查待关闭

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
            if self.formerState == "重复的" or self.formerState == "无效的" or self.formerState == "待信息补充":
                self.valid = False
        if self.submitTime.year < YEAR_FILTER:
            self.valid = False
        if self.modifyFinishTime == "" and self.type == "缺陷":
            self.bugAlarmFlag = True
        if self.product == "":
            self.valid = False

    def calcDiff(self):
        if self.assignTime:
            self.assignDiff = numpy.busday_count(self.submitTime.date(), self.assignTime.date()) + 1
        if self.modifyFinishTime:
            self.modifyDiff = numpy.busday_count(self.submitTime.date(), self.modifyFinishTime.date()) + 1
        if self.resolveTime:
            self.resolveDiff = numpy.busday_count(self.submitTime.date(), self.resolveTime.date()) + 1
        if self.closeTime:
            self.closeDiff = numpy.busday_count(self.submitTime.date(), self.closeTime.date()) + 1

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
        if self.type.find("缺陷") != -1:
            member.bugNum += 1
            group.bugNum += 1
            product.bugNum += 1
            if member.id == self.owner:
                if self.state == "已提出" or self.state == "已分派":
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
                if member.id == self.fixer:
                    member.close += 1
                    group.close += 1
                    product.close += 1
                    member.bugModifyTimeSum += self.modifyDiff
                    member.bugResolveTimeSum += self.resolveDiff
                    member.bugCloseTimeSum += self.closeDiff
                    group.bugModifyTimeSum += self.modifyDiff
                    group.bugResolveTimeSum += self.resolveDiff
                    group.bugCloseTimeSum += self.closeDiff
                    product.bugModifyTimeSum += self.modifyDiff
                    product.bugResolveTimeSum += self.resolveDiff
                    product.bugCloseTimeSum += self.closeDiff
        if self.type == "研发自查":
            if self.detailVer.find("内部版本") != -1:
                if self.submitter in memberDic:
                    memberSubmit.zc1Num += 1
                    groupSubmit.zc1Num += 1
                    product.zc1Num += 1
                    if self.state != "已关闭":
                        memberSubmit.zc1TobeCloseNum += 1
                        groupSubmit.zc1TobeCloseNum += 1
                        product.zc1TobeCloseNum += 1
                        if isAlarmZc(self.submitTime, ZC1_DIFF) == True:
                            self.zcTodoFlag = True
                            member.zc1TodoNum += 1 
            else: # 正式版本研发自查
                if self.submitter in memberDic:
                    memberSubmit.zc2Num += 1
                    groupSubmit.zc2Num += 1
                    product.zc2Num += 1
                if self.state != "已关闭":
                    member.zc2TobeCloseNum += 1
                    group.zc2TobeCloseNum += 1
                    product.zc2TobeCloseNum += 1
                    if isAlarmZc(self.submitTime, ZC2_DIFF) == True:
                        self.zcTodoFlag = True
                        member.zc2TodoNum += 1
                else:
                    if member.id == self.fixer:
                        member.zc2ClosedNum += 1
                        group.zc2ClosedNum += 1
                        product.zc2ClosedNum += 1
                        member.zc2ResolveTimeSum += self.resolveDiff
                        member.zc2CloseTimeSum += self.closeDiff
                        group.zc2ResolveTimeSum += self.resolveDiff
                        group.zc2CloseTimeSum += self.closeDiff
                        product.zc2ResolveTimeSum += self.resolveDiff
                        product.zc2CloseTimeSum += self.closeDiff

def division(a, b):
    return round((a / b), 1) if b != 0 else 0

def isAlarmZc(submitTime, threshould):
    diff = numpy.busday_count(submitTime.date(), datetime.now().date()) + 1
    if diff >= threshould:
        return True
    else:
        return False

WRITE_TYPE_ALL = 0
WRITE_TYPE_BUG = 1
WRITE_TYPE_ZC = 2

def isWrite(bugInfo, type):
    if type == WRITE_TYPE_BUG:
        return bugInfo.bugAlarmFlag
    elif type == WRITE_TYPE_ZC:
        return bugInfo.zcTodoFlag
    else:
        return True

def getTimeStr(dateTimeObject):
    if dateTimeObject:
        return dateTimeObject.strftime("%Y-%m-%d")
    else:
        return ""

def writeBugInfo(bugInfoList, hlBugFp, alarmFlag=WRITE_TYPE_ALL):
    for item in TITLE_LIST_BUG:
        hlBugFp.write(item + ",")
    hlBugFp.write("\n")
    for bugInfo in bugInfoList:
        if isWrite(bugInfo, alarmFlag) == False:
            continue
        hlBugFp.write(str(bugInfo.BugNum) + " ,")
        hlBugFp.write(str(bugInfo.title) + " ,")
        hlBugFp.write(getTimeStr(bugInfo.submitTime) + " ,")
        hlBugFp.write(bugInfo.state + " ,")
        hlBugFp.write(bugInfo.rank + " ,")
        hlBugFp.write(getTimeStr(bugInfo.assignTime) + " ,")
        hlBugFp.write(getTimeStr(bugInfo.modifyFinishTime) + " ,")
        hlBugFp.write(bugInfo.product + " ,")
        hlBugFp.write(bugInfo.ver + " ,")
        hlBugFp.write(bugInfo.owner + " ,")
        hlBugFp.write(bugInfo.submitter + " ,")
        hlBugFp.write(bugInfo.fixer + " ,")
        hlBugFp.write(bugInfo.firstFixer + " ,")
        hlBugFp.write(bugInfo.type + " ,")
        hlBugFp.write(getTimeStr(bugInfo.invalidTime) + " ,")
        hlBugFp.write(getTimeStr(bugInfo.duplicateTime) + " ,")
        hlBugFp.write(getTimeStr(bugInfo.resolveTime) + " ,")
        hlBugFp.write(getTimeStr(bugInfo.postponeTime) + " ,")
        hlBugFp.write(bugInfo.subsystem + " ,")
        hlBugFp.write(bugInfo.formerState + " ,")
        hlBugFp.write(getTimeStr(bugInfo.closeTime) + " ,")
        hlBugFp.write(bugInfo.detailVer + ",")
        hlBugFp.write(bugInfo.hlName + " ,")
        hlBugFp.write(str(bugInfo.valid) + " ,")
        hlBugFp.write(str(bugInfo.assignDiff) + " ,")
        hlBugFp.write(str(bugInfo.modifyDiff) + " ,")
        hlBugFp.write(str(bugInfo.resolveDiff) + " ,")
        hlBugFp.write(str(bugInfo.closeDiff) + " ,")
        hlBugFp.write("\n")

def writeMember(memberDic, memberFp):
    for item in TITLE_LIST_MEMBER:
        memberFp.write(item + ",")
    memberFp.write("\n")
    for key in memberDic.keys():
        memberDic[key].calc()
        if memberDic[key].valid == 0:
            continue
        memberFp.write(memberDic[key].name + ",")
        memberFp.write(memberDic[key].id + ",")
        memberFp.write(memberDic[key].group + ",")
        memberFp.write(str(memberDic[key].crNum) + ",")
        memberFp.write(str(memberDic[key].bugNum) + ",")
        memberFp.write(str(memberDic[key].tobeOpen) + ",")
        memberFp.write(str(memberDic[key].tobeModify) + ",")
        memberFp.write(str(memberDic[key].tobeResolve) + ",")
        memberFp.write(str(memberDic[key].tobeClose) + ",")
        memberFp.write(str(memberDic[key].close) + ",")
        memberFp.write(str(memberDic[key].bugModifyTimeAverage) + ",")
        memberFp.write(str(memberDic[key].bugResolveTimeAverage) + ",")
        memberFp.write(str(memberDic[key].bugCloseTimeAverage) + ",")
        memberFp.write(str(memberDic[key].zc1Num) + ",")
        memberFp.write(str(memberDic[key].zc1TobeCloseNum) + ",")
        memberFp.write(str(memberDic[key].zc2Num) + ",")
        memberFp.write(str(memberDic[key].zc2TobeCloseNum) + ",")
        memberFp.write(str(memberDic[key].zc2ClosedNum) + ",")
        memberFp.write(str(memberDic[key].zc2ResolveTimeAverage) + ",")
        memberFp.write(str(memberDic[key].zc2CloseTimeAverage) + ",")
        memberFp.write("\n")

def writeMemberZcNum(memberDic, memberFp):
    for item in TITLE_LIST_MEMBER_ZC:
        memberFp.write(item + ",")
    memberFp.write("\n")
    for key in memberDic.keys():
        if memberDic[key].valid == 0:
            continue
        if memberDic[key].zc1TodoNum != 0 or memberDic[key].zc2TodoNum != 0:
            memberFp.write(memberDic[key].name + ",")
            memberFp.write(str(memberDic[key].zc1TodoNum) + ",")
            memberFp.write(str(memberDic[key].zc2TodoNum) + ",")
            memberFp.write("\n")

def writeGroup(groupDic, groupFp):
    for item in TITLE_LIST_GROUP:
        groupFp.write(item + ",")
    groupFp.write("\n")
    for key in groupDic.keys():
        groupDic[key].calc()
        groupFp.write(groupDic[key].group + ",")
        groupFp.write(str(groupDic[key].crNum) + ",")
        groupFp.write(str(groupDic[key].bugNum) + ",")
        groupFp.write(str(groupDic[key].unModifyRatio) + ",")
        groupFp.write(str(groupDic[key].tobeResolveRatio) + ",")
        groupFp.write(str(groupDic[key].tobeCloseRatio) + ",")
        groupFp.write(str(groupDic[key].closeRatio) + ",")
        groupFp.write(str(groupDic[key].bugModifyTimeAverage) + ",")
        groupFp.write(str(groupDic[key].bugResolveTimeAverage) + ",")
        groupFp.write(str(groupDic[key].bugCloseTimeAverage) + ",")
        groupFp.write(str(groupDic[key].zc1Num) + ",")
        groupFp.write(str(groupDic[key].zc1TobeCloseRatio) + ",")
        groupFp.write(str(groupDic[key].zc2Num) + ",")
        groupFp.write(str(groupDic[key].zc2TobeCloseRatio) + ",")
        groupFp.write(str(groupDic[key].zc2ResolveTimeAverage) + ",")
        groupFp.write(str(groupDic[key].zc2CloseTimeAverage) + ",")
        groupFp.write("\n")


memberfp = open("member.txt", "r")
memberDic = {}
groupDic = {}
for num, eachLine in enumerate(memberfp):
    member = memberClass(eachLine.rstrip())
    memberDic[member.id] = member
    if member.group not in groupDic:
        groupDic[member.group] = groupClass(member.group)
memberfp.close()


#bugFp = open("K:\\work\\GitHub\\Python\\bugAnalyse\\test.csv", "r")


bugCount = 0
bugVliadCount = 0

# 遍历所有bug，统计出属于HL的有效BUG
bugInfoList = []
productDic = {}
logErr = open('logErr.txt', 'w')

bugFileName = input("bug CSV: ")
bugFp = open(bugFileName, "rb")
allCount = 0
bugCount = 0
bugVliadCount =0
for num, eachLine in enumerate(bugFp):
    try:
        #尝试用GBK解码
        eachLine = eachLine.decode('gbk')
        bugInfo = BugInfoClass(eachLine.replace("\"", ""))
        bugInfo.filter(memberDic)
        bugCount += 1
        if bugInfo.hlName != "" and bugInfo.valid is True:
            if bugInfo.product not in productDic:
                productDic[bugInfo.product] = groupClass(bugInfo.product)
            bugInfoList.append(bugInfo)
            bugInfo.calcDiff()
            bugInfo.count(memberDic, groupDic, productDic)  # 按照规则统计到人、资源组、项目名下
            bugVliadCount += 1
        allCount += 1
        # print(bugInfo.BugNum)
        # print(bugInfo.fomrerState)
    except Exception as e:
        logErr.write(str(e))
        logErr.write("行号" + str(num) + "\n")
logErr.close()

print(allCount, bugCount, bugVliadCount, len(bugInfoList))
bugFp.close()


hlBugFp = open("bugInfo.csv", "w")
writeBugInfo(bugInfoList, hlBugFp)
hlBugFp.close()

bugAlarmFp = open("BUG推动.csv", "w")
writeBugInfo(bugInfoList, bugAlarmFp, WRITE_TYPE_BUG)
bugAlarmFp.close()

zcAlarmFp = open("研发自查推动.csv", "w")
writeBugInfo(bugInfoList, zcAlarmFp, WRITE_TYPE_ZC)
zcAlarmFp.close()

memberFp = open("人员统计.csv", "w")
writeMember(memberDic, memberFp)
memberFp.close()

memberZcFp = open("研发自查推动人员统计.csv", "w")
writeMemberZcNum(memberDic, memberZcFp)
memberZcFp.close()

groupFp = open("资源组统计.csv", "w")
writeGroup(groupDic, groupFp)
groupFp.close()

productFp = open("项目统计.csv", "w")
writeGroup(productDic, productFp)
productFp.close()

print('处理成功\n')
