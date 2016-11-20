import os, codecs
import re
import xlwt
from os.path import join, getsize


#filedir = r'D:\ViewRoot\chengengyu_Merge\EMB5216_L2'
filedir = r'D:\ViewRoot\RRM\EMB5216_HL'
#filedir = r'D:\learn\HL DBA函数解析\now'

class Funline(object):
    def __init__(self):
        self.FunName = False;
        self.FunLineCount = 0;
        self.FunStart = 0;
        self.FunEnd = 0;
        self.FunFileName = False;
    
def findfiles(filedir):
    filelist = []
    filename_file = open('filename.txt','w')
    for root, dirs, files in os.walk(filedir):
        if files:
            for name in files:
                if re.search('.c$', name):
                    filelist.append(join(root, name))               
                    filename_file.write(name+'\n')
    filename_file.close
    return filelist

#获取文件列表
filelist = findfiles(filedir)
fun_check_result = open('fun_check_result.txt','w')
fun_check_errLine = open('fun_check_errLine.txt','w')

FunLineList = []
for file in filelist:
    filename = ''
    filename = re.findall(r'\\([^\\]+\.c)$', file)
    try:
        fp = codecs.open(file,'rb')
        #fp = open(file,'r')
        #print(file)
        FirstFunFlag = True
        LastFunFlag = False
        FunLineNum = 0
        for num,eachline in enumerate(fp):         
            try:
                #尝试用 gbk解码
                eachline = eachline.decode('GBK')
                linetemp = eachline.strip()
                if re.search(r'^(?:void|s32|OSP_STATUS|u32|u8|u16|s8|s16) +\S+(?:$|\s*\(.*(,|\)))', linetemp):
                    if not re.search(r';|extern', linetemp):
                        if FirstFunFlag == False:      #不是第一个函数则需要记录其行数
                            #print(num, FunlineNum)
                            if fun.FunLineCount != 0:
                                fun_check_result.write("异常内容fun:" + fun.FunName + eachline + '\n')
                            else:
                                fun.FunLineCount = num - FunLineNum
                                fun.FunStart = FunLineNum
                                fun.FunEnd = num
                        fun = Funline()
                        FunLineList.append(fun)
                        FirstFunFlag = False
                        FunLineNum = num  #记录函数开始的行数
                        LastFunFlag = True #假定这是最后一个函数
                        if fun.FunName != False:
                           fun_check_result.write("异常内容fun:" + eachline + '\n')
                        else:
                            fun.FunName = linetemp
                            fun.FunFileName = filename
            except Exception as e:
                #解析失败，通常是因为一些汉字的半角全角有问题        
                print(e)
                fun_check_errLine.write(str(e))
                err = "无法解析的行: 文件为" + file + "行号为:" + str(num+1) + '\n'
                fun_check_errLine.write(err)
        fp.close
        if LastFunFlag:
            if fun.FunLineCount != 0:
               fun_check_result.write("异常内容fun:" + fun.FunName + eachline + '\n')
            else:
                fun.FunLineCount = num - FunLineNum
                fun.FunStart = FunLineNum
                fun.FunEnd = num
    except Exception as e:
        print(e)
        fun_check_errLine.write(str(e))
        err = '无法打开文件' + file +'\n'
        fun_check_result.write(err)

fun_check_result.close()
fun_check_errLine.close()

#print(FunLineList)

styles = {'datetime': xlwt.easyxf(num_format_str='yyyy-mm-dd hh:mm:ss'),
          'date': xlwt.easyxf(num_format_str='yyyy-mm-dd'),
          'time': xlwt.easyxf(num_format_str='hh:mm:ss'),
          'header': xlwt.easyxf('font: name Times New Roman, color-index black, bold on', num_format_str='#,##0.00'),
          'default': xlwt.Style.default_style}

wb = xlwt.Workbook(encoding = 'utf-8')
sheet = wb.add_sheet(u'函数')
row = 0
sheet.write(row,0, '文件名')
sheet.write(row,1, '函数名')
sheet.write(row,2, '行数')
sheet.write(row,3, '开始行数')
sheet.write(row,4, '结束行数')
for num,eachitem in enumerate(FunLineList):     
    row = num + 1
    sheet.write(row,0, eachitem.FunFileName)
    sheet.write(row,1, eachitem.FunName)
    sheet.write(row,2, eachitem.FunLineCount)
    sheet.write(row,3, eachitem.FunStart)
    sheet.write(row,4, eachitem.FunEnd)
wb.save('fun.xls')
