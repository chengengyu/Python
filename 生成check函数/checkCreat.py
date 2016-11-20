import os, codecs
import re
from os.path import join, getsize



def getStruName(fileDef):
    for line in fileDef:
        print(line)
        struNameObject = re.findall(r'}((\w|_)+);', line)
        print(struNameObject)
        print(line)
        if struNameObject:
            print(struNameObject[0][0])
            struName = re.sub(r'_', "", struNameObject[0][0])
            return struName



def getVarNameList(fileDef):
    NameList = []
    for line in fileDef:
        print(line)
        code = re.split(r'/*', line)[0]   #提取注释前的代码
        print(code)
        VarName = re.search(r'.+ ((\w|_|\[|\])+);', code)
        print(VarName)
        if VarName:
            NameList.append(VarName.group(1))
    return NameList


fileDef = open('def.txt','r')
fileFun = open('fun.txt','w')

struName = getStruName(fileDef)
fileDef.close()
fileDef = open('def.txt','r')
NameList = getVarNameList(fileDef)
VarSource = "pstru" + struName
VarCheck = VarSource + "Check"
funDef = "void HL_" + struName + "Check(" + struName + " *" + VarSource + ", " + struName + " *" + VarCheck + ")\n"
fun = funDef + "{\n"
for VarName in NameList:
    VarSourceName = VarSource + "->" + VarName
    VarCheckName = VarCheck + "->" + VarName
    funLine = "    CHECK_EQUAL_TEXT(" + VarCheckName + ",  " + VarSourceName + ",  " + "\"" + VarSourceName + "\");\n"
    fun = fun + funLine
fun = fun + "}\n"

fileFun.write(fun)

fileFun.close()
fileDef.close()




