import os, codecs
import re
from os.path import join, getsize


def getFunName(struName):
    struName = re.sub(r'_', "", struName)
    return "HL_" + struName + "Check"

def splitStructCode(fileDefStr):
    return re.findall(r'(typedef +struct\s*{.+?} *[\w|_]+;)', fileDefStr, re.S)

def IsStruct(string):
    return re.search(r'^stru', string)

class StructClass(object):
    def __init__(self):
        self.struName = ""
        self.struNameHld = ""
        self.VarNameList = []
        self.VarStructNameList = []
        self.VarSource = ""
        self.VarCheck = ""
        self.VarLoopFlag = False
        self.fun = ""

    def setStruName(self, code):
        self.struName = re.findall(r'}([\w|_]+);', code)[0]
        self.struNameHld = re.sub(r'_', "", self.struName)

    def setVarNameList(self, code):
        codeLine = re.split(r'\n', code)
        for line in codeLine:
            print(line)
            codeSplit = re.split(r'/*', line)[0]   #提取注释前的代码
            print(codeSplit)
            VarName = re.search(r' *([\w|_]+) +([\w|_|\[|\]]+);', codeSplit)
            print(VarName)
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
                else:
                    self.fun = self.fun + "        CHECK_EQUAL_TEXT(" + VarCheckName + ",  " + VarSourceName + ",  " + "\"" + VarSourceName + "\");\n"
                self.fun = self.fun + "    }\n\n"
            else:
                VarSourceName = self.VarSource + "->" + VarName
                VarCheckName = self.VarCheck + "->" + VarName
                if re.search(r'^stru', VarName):
                    self.fun = self.fun + "    " + getFunName(self.VarStructNameList[linenum]) + "(&" + VarSourceName + ", &" + VarCheckName + ");\n"
                else:
                    self.fun = self.fun + "    CHECK_EQUAL_TEXT(" + VarCheckName + ",  " + VarSourceName + ",  " + "\"" + VarSourceName + "\");\n"
        self.fun = self.fun + "    return;\n}\n\n\n"

    def creatfun(self, code):
        self.setStruName(code)
        self.setVarNameList(code)
        self.setVarSource()
        self.setVarCheck()
        self.setfun()



fileDef = open('def.txt','r')
fileFun = open('fun.txt','w')

fileDefStr = fileDef.read()
codeList = splitStructCode(fileDefStr)
for code in codeList:
    structInstance = StructClass()
    structInstance.creatfun(code)
    fileFun.write(structInstance.fun)

fileFun.close()
fileDef.close()




