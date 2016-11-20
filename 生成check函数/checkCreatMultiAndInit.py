'''
1. chengengyu creat 2016/10/30
2. chengengyu fix union 2016/11/01
3. chengengyu add expand InitFun 2016/11/20
'''


import os, codecs
import re
from os.path import join, getsize

funEnd = "\n    return;\n}\n\n\n"

def getFunName(struName):
    struName = re.sub(r'_', "", struName)
    return "HL_" + struName + "Check"

def getInitFunName(struName):
    struName = re.sub(r'_', "", struName)
    return "HL_" + struName + "Init"

def splitStructCode(fileDefStr):
    return re.findall(r'(typedef +struct\s*{.+?} *(?!u)(?:[\w|_]+);)', fileDefStr, re.S)

def IsStruct(string):
    return re.search(r'^stru', string)

def IsStrucPoint(string):
    return re.search(r'^pstru', string)

def IsStructOrStructPoint(string):
    return IsStruct(string) or IsStrucPoint(string)

def findfiles(filedir):
    filelist = []
    filename_file = open('filename.txt','w')
    for root, dirs, files in os.walk(filedir):
        if files:
            for name in files:
                if re.search('.h$', name):
                    filelist.append(name)
                    filename_file.write(name+'\n')
    filename_file.close
    return filelist

def GetStructInstanceFromVarName(VarStructName, structInstanceList):
    for Instance in structInstanceList:
        if VarStructName == Instance.struName:
            return Instance
    return ""

def GetMemberList(VarNameIn, VarStructName, structInstanceList):
    memberListReturn = []
    VarNameCode = ""
    Link = ""
    if IsStruct(VarNameIn):
        Link = "."
    else:
        Link = "->"
    structInstance =  GetStructInstanceFromVarName(VarStructName, structInstanceList)
    if structInstance:
        for linenum, VarName in enumerate(structInstance.VarNameList):
            if IsStructOrStructPoint(VarName):
                memberList = GetMemberList(VarName, self.VarStructNameList[linenum], structInstanceList)
                for member in memberList:
                    VarNameCode = VarNameIn + Link + member
                    memberListReturn.append(VarNameCode)
            else:
                VarNameCode = VarNameIn + Link + VarName
                memberListReturn.append(VarNameCode)
    else:
        VarNameCode = VarNameIn
        memberListReturn.append(VarNameCode)
    return memberListReturn
#def getPoint(string):
#    return string

class StructClass(object):
    def __init__(self, code):
        self.struName = ""           #结构体定义的原始名字
        self.struNameHld = ""        #除去结构体定义中的下划线
        self.VarNameList = []        #存放结构体中的变量名
        self.VarStructNameList = []  #结构体变量如果是结构体，存储对应的定义
        self.VarSource = ""          #函数中用此结构体定义的变量
        self.VarCheck = ""           #函数中用此结构体定义的变量的check形式
        self.VarLoopFlag = False     #结构体是否有数组
        self.fun = ""                #check函数
        self.initFun =""             #未展开的init函数
        self.externfun = ""          #check函数的声明
        self.initFunExpand = ""      #展开的init函数
        self.setStruName(code)       
        self.setVarNameList(code)
        self.setVarSource()
        self.setVarCheck()

    def setStruName(self, code):
        self.struName = re.findall(r'} *(?!u)([\w|_]+);', code)[0]
        self.struNameHld = re.sub(r'_', "", self.struName)

    def setVarNameList(self, code):
        codeLine = re.split(r'\n', code)
        for line in codeLine:
            #print(line)
            codeSplit = re.split(r'/*', line)[0]   #提取注释前的代码
            #print(codeSplit)
            VarName = re.search(r' *([\w|_]+) +([\w|_|\[|\]]+);', codeSplit)
            #print(VarName)
            if VarName:
                self.VarNameList.append(VarName.group(2))
                self.VarStructNameList.append(VarName.group(1))
                if re.search(r'\[', VarName.group(2)):
                    self.VarLoopFlag = True

    def setVarSource(self):
        self.VarSource = "pstru" + self.struNameHld

    def setVarCheck(self):
        self.VarCheck = self.VarSource + "Check"

    def setfun(self):
        self.fun = "void " + getFunName(self.struNameHld) + "(" + self.struName + " *" + self.VarSource + ", " + self.struName + " *" + self.VarCheck + ")\n{\n"
        if self.VarLoopFlag:
            self.fun = self.fun + "    u32    u32i;\n\n"
        for linenum, VarName in enumerate(self.VarNameList):
            VarryObject = re.search(r'([\w|_]+)\[([\w|_]+)\]', VarName)
            if VarryObject:
                VarName = VarryObject.group(1)
                VarSourceName = self.VarSource + "->" + VarName + "[u32i]"
                VarCheckName = self.VarCheck + "->" + VarName + "[u32i]"
                self.fun = self.fun + "\n    for(u32i = 0; u32i < " + VarryObject.group(2) + "; u32i++)\n    {\n"
                if IsStruct(VarName):
                    self.fun = self.fun + "        " + getFunName(self.VarStructNameList[linenum]) + "(&" + VarSourceName + ", &" + VarCheckName + ");\n"
                elif IsStrucPoint(VarName):
                    self.fun = self.fun + "        " + getFunName(self.VarStructNameList[linenum]) + "(" + VarSourceName + ", " + VarCheckName + ");\n"
                else:
                    self.fun = self.fun + "        CHECK_EQUAL_TEXT(" + VarCheckName + ",  " + VarSourceName + ",  " + "\"" + VarSourceName + "\");\n"
                self.fun = self.fun + "    }\n\n"
            else:
                VarSourceName = self.VarSource + "->" + VarName
                VarCheckName = self.VarCheck + "->" + VarName
                if IsStruct(VarName):
                    self.fun = self.fun + "    " + getFunName(self.VarStructNameList[linenum]) + "(&" + VarSourceName + ", &" + VarCheckName + ");\n"
                elif IsStrucPoint(VarName):
                    self.fun = self.fun + "    " + getFunName(self.VarStructNameList[linenum]) + "(" + VarSourceName + ", " + VarCheckName + ");\n"
                else:
                    self.fun = self.fun + "    CHECK_EQUAL_TEXT(" + VarCheckName + ",  " + VarSourceName + ",  " + "\"" + VarSourceName + "\");\n"
        self.fun = self.fun + funEnd
        
    def setInitFunExpand(self, structInstanceList):
        self.initFunExpand = "void " + getInitFunName(self.struNameHld) + "( )\n{\n"
        self.initFunExpand = self.initFunExpand + "    " + self.struName + "  *" + self.VarSource + ";\n\n"
        initCode = ""
        for linenum, VarName in enumerate(self.VarNameList):
            memberList = []
            VarSourceName = self.VarSource + "->"
            if IsStructOrStructPoint(VarName):
                memberList = GetMemberList(VarName, self.VarStructNameList[linenum], structInstanceList)
                for member in memberList:
                    initCode = initCode + "    " + VarSourceName + member + " = ;\n"
            else:
                initCode = initCode + "    " + VarSourceName + VarName + " = ;\n"
        #for line in initCode:
        self.initFunExpand = self.initFunExpand + initCode + funEnd

    def setInitFun(self):
        self.initFun = "void " + getInitFunName(self.struNameHld) + "( )\n{\n"
        self.initFun = self.initFun + "    " + self.struName + "  *" + self.VarSource + ";\n"
        for linenum, VarName in enumerate(self.VarNameList):
            VarryObject = re.search(r'([\w|_]+)\[([\w|_]+)\]', VarName)
            if VarryObject:
                VarName = VarryObject.group(1)
                VarSourceName = self.VarSource + "->" + VarName + "[u32i]"
                self.initFun = self.initFun + "\n    for(u32i = 0; u32i < " + VarryObject.group(2) + "; u32i++)\n    {\n"
                if IsStruct(VarName):
                    self.initFun = self.initFun + "        " + VarSourceName + " = ;\n"
                else:
                    self.initFun = self.initFun + "        " + VarSourceName + " = ;\n"
                self.initFun = self.initFun + "    }\n\n"
            else:
                VarSourceName = self.VarSource + "->" + VarName
                if re.search(r'^stru', VarName):
                    self.initFun = self.initFun + "    " + VarSourceName + " = ;\n"
                else:
                    self.initFun = self.initFun + "    " + VarSourceName + " = ;\n"
        self.initFun = self.initFun + funEnd
    def setExternfun(self):
        self.externfun = "extern void " + getFunName(self.struNameHld) + "(" + self.struName + " *" + self.VarSource + ", " + self.struName + " *" + self.VarCheck + ");\n"

    def creatfun(self, StructList):
        self.setfun()
        self.setInitFun()
        self.setExternfun()
        self.setInitFunExpand(StructList)


fileList = findfiles(os.curdir)

for headFile in fileList:
    funFileName = re.split("\.", headFile)[0]
    fileDef = open(headFile,'r')
    fileFunCheck = open("check_" + funFileName + ".cpp",'w')
    fileFunInit = open("Init_" + funFileName + ".cpp",'w')
    fileFunExtern = open("check_" + funFileName + ".h",'w')

    fileDefStr = fileDef.read()
    codeList = splitStructCode(fileDefStr)
    structInstanceList = []
    for code in codeList:
        structInstance = StructClass(code)
        structInstanceList.append(structInstance)
    for Instance in structInstanceList:
        Instance.creatfun(structInstanceList)
        fileFunCheck.write(Instance.fun)
        fileFunInit.write(Instance.initFunExpand)
        fileFunExtern.write(Instance.externfun)
    fileDef.close()
    fileFunCheck.close()
    fileFunInit.close()



