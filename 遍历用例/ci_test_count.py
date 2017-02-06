import os
import codecs
import re
import xlwt
from os.path import join, getsize

ciName = r''

class CiModule():
    def __init__(self):
        self.ModuleName = ""
        self.TestList = []


class CiTest():
    def __init__(self):
        self.FunName = ""
        self.TestName = ""

def findfiles(filedir):
    filelist = []
    filename_file = open('filename.txt', 'w')
    for root, dirs, files in os.walk(filedir):
        if files:
            for name in files:
                if re.search('.cpp$', name):
                    filelist.append(join(root, name))
                    filename_file.write(name+'\n')
    filename_file.close
    return filelist

#获取文件列表
filelist = findfiles(os.curdir)
fun_check_errLine = open('fun_check_errLine.txt','w')

moduleName = ""
moduleNamePrev = ""
CiModuleList = []
for file in filelist:
    filename = ""
    filename = re.findall(r'\\([^\\]+\.c)$', file)
    moduleName = re.findall(r'', file)
    if moduleName != moduleNamePrev:
        CiModuleIns = CiModule()
        CiModuleIns.ModuleName = moduleName
        CiModuleList.append(CiModuleIns)
        moduleNamePrev = moduleName
    try:
        fp = codecs.open(file, 'rb')
        FunLineNum = 0
        for num, eachline in enumerate(fp):
            try:
                #尝试用 gbk解码
                eachline = eachline.decode('GBK')
                linetemp = eachline.strip()
                ciTestSearch = re.search(ciName, linetemp)
                if ciTestSearch:
                    ciTestIns = CiTest()
                    ciTestIns.FunName = ciTestSearch.group(1)
                    ciTestIns.TestName = ciTestSearch.group(2)
                    CiModuleIns.TestList.append(ciTestIns)
            except Exception as e:  #解析失败，通常是因为一些汉字的半角全角有问题
                print(e)
                fun_check_errLine.write(str(e))
                err = "无法解析的行: 文件为" + file + "行号为:" + str(num+1) + '\n'
                fun_check_errLine.write(err)
        fp.close
    except Exception as e:
        print(e)
        fun_check_errLine.write(str(e))
        err = '无法打开文件' + file +'\n'
        fun_check_errLine.write(err)

fun_check_errLine.close()

#print(CiTestList)

wb = xlwt.Workbook(encoding = 'utf-8')
sheet = wb.add_sheet(u"汇总")
row = 0
sheet.write(row, 0, '序号')
sheet.write(row, 1, '模块名')
sheet.write(row, 2, '用例个数')
for num, eachitem in enumerate(CiModuleList):
    row = num + 1
    sheet.write(row, 0, row)
    sheet.write(row, 1, eachitem.ModuleName)
    sheet.write(row, 2, eachitem.TestList.count)

for moduleIns in CiModuleList:
    sheet = wb.add_sheet(moduleIns.ModuleName)
    row = 0
    sheet.write(row, 0, '序号')
    sheet.write(row, 1, '函数名')
    sheet.write(row, 2, '用例名')
    for num, eachitem in enumerate(moduleIns.TestList):
        row = num + 1
        sheet.write(row, 0, row)
        sheet.write(row, 1, eachitem.FunName)
        sheet.write(row, 2, eachitem.TestName)
wb.save('fun.xls')
