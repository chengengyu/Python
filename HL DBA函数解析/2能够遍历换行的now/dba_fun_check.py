import os, codecs
import re
import xlwt
from os.path import join, getsize




filedir = r'D:\ViewRoot\chengengyu_view_FddRrm\EMB5216_HL'
#filedir = r'D:\learn\HL DBA函数解析\now'

class DbAcesssFun(object):
    def __init__(self):
        self.DaAcessFlag = False;
        self.FunName = False;
        self.table = False;
        self.index = False;
        self.recno = False;
            
    
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
#print(filelist)
db_check_result = open('db_check_result.txt','w')
db_check_errLine = open('db_check_errLine.txt','w')

DbFunList = []
for file in filelist:
    filename = ''
    filename = re.findall(r'\\([^\\]+\.c)$', file)
    try:
        fp = codecs.open(file,'rb')
        #fp = open(file,'r')
        #print(file)
        Index4OtherLineFlag = False 
        for num,eachline in enumerate(fp):         
            try:
                #尝试用 gbk解码
                eachline = eachline.decode('GBK')
                linetemp = eachline.strip()
                if re.search(r'^(?:void|s32|OSP_STATUS|u32|u8|u16|s8|s16) +\S+(?:$|\s*\(.*(,|\)))', linetemp):
                    if not re.search(r';|extern', linetemp):
                        fun = DbAcesssFun()
                        DbFunList.append(fun)
                        #print(linetemp)
                        #db_check_result.write(eachline)
                        if fun.FunName != False:
                           db_check_result.write("异常内容fun:" + eachline + '\n')
                        else:
                            fun.FunName = linetemp
                objTable = re.search(r'u32Table *= *(.*);',eachline)
                objIndex = re.search(r'struSerIn.u32Index *= *(.*);',eachline)
                objDbAcess = re.search(r'DB_Access\(.*\);',eachline)
                objRecno = re.search(r'u32recno *= *(.*);',eachline)
                if objTable:
                    if fun.table != False:
                        db_check_result.write("异常内容table:" + '行' + str(num) + '函数' + fun.FunName + '\n')
                    else:
                        fun.table = objTable.group(1)
                elif objIndex:
                    if fun.index != False:
                        db_check_result.write("异常内容Index:" + fun.FunName + '\n')
                    else:
                        fun.index = objIndex.group(1)
                elif objRecno:
                    if fun.recno != False:
                        db_check_result.write("异常内容Recno:" + fun.FunName + '\n')
                    else:
                        fun.recno = objRecno.group(1)
                elif objDbAcess:
                    if fun.DaAcessFlag != False:
                        db_check_result.write("异常内容DbAcess:" + fun.FunName + '\n')
                    else:
                        fun.DaAcessFlag = True
                else:
                    #针对index换行赋值的情况
                    if Index4OtherLineFlag:  #上一行是换行的情况
                        Index4OtherLineFlag = False
                        objIndex4OtherLine2 = re.search(r'=\s*(g_.*);',eachline)
                        if objIndex4OtherLine2:
                            if fun.index != False:
                                db_check_result.write("异常内容objIndex4OtherLine2:" + fun.FunName + '\n')
                            else:
                                fun.index = objIndex4OtherLine2.group(1)
                    else:
                        objIndex4OtherLine = re.search(r'struSerIn.u32Index\s*(/\*.*\*/)?',eachline)
                        if objIndex4OtherLine:  
                            Index4OtherLineFlag = True   #说明换行，置标记，下一行需要特殊的判断
            except Exception as e:
                #解析失败，通常是因为一些汉字的半角全角有问题        
                print(e)
                db_check_errLine.write(str(e))
                err = "无法解析的行: 文件为" + file + "行号为:" + str(num+1) + '\n'
                db_check_errLine.write(err)
        fp.close
    except Exception as e:
        print(e)
        db_check_errLine.write(str(e))
        err = '无法打开文件' + file +'\n'
        db_check_result.write(err)

db_check_result.close()
db_check_errLine.close()

#print(DbFunList)

db_check_fun = open('db_check_fun.txt','w')
if DbFunList:
    print('wll')
for eachitem in DbFunList:
    #print(eachitem.FunName)
    #print(eachitem.DaAcessFlag)
    #db_check_fun.write(eachitem.FunName + '\n')
    db_check_fun.write(str(eachitem.FunName) + str(eachitem.DaAcessFlag) + str(eachitem.table) + str(eachitem.index) + '\n')
db_check_fun.close()




styles = {'datetime': xlwt.easyxf(num_format_str='yyyy-mm-dd hh:mm:ss'),
          'date': xlwt.easyxf(num_format_str='yyyy-mm-dd'),
          'time': xlwt.easyxf(num_format_str='hh:mm:ss'),
          'header': xlwt.easyxf('font: name Times New Roman, color-index black, bold on', num_format_str='#,##0.00'),
          'default': xlwt.Style.default_style}

wb = xlwt.Workbook(encoding = 'utf-8')
sheet = wb.add_sheet(u'函数')
for num,eachitem in enumerate(DbFunList):     
    row = num
    sheet.write(row,0, eachitem.FunName)
    sheet.write(row,1, eachitem.DaAcessFlag)
    sheet.write(row,2, eachitem.table)
    sheet.write(row,3, eachitem.index)
    sheet.write(row,4, eachitem.recno)
wb.save('fun.xls')
