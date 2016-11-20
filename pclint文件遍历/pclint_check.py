__author__ = 'chengengyu'

import os, codecs
import re
import xlwt
from openpyxl import Workbook


class Pclint(object):
    def __init__(self):
        self.Event = False
        self.info = ''
        self.type = []

check_result = open('check_result.txt','w')
check_errLine = open('check_errLine.txt','w')

try:
    fp = open('pclint.txt', 'r')
except:
    print('无法打开pclint.txt')

pclintlist = []
StartFlag = False
pclintline = Pclint()
for eachline in fp:
    linetemp = eachline.strip()
    if re.search(r'^_$', linetemp):
        pclintline = Pclint()
        pclintlist.append(pclintline)
        StartFlag = True
        continue
    if StartFlag == True:
        pclintline.Event = linetemp
        StartFlag = False
        continue
    if pclintline.Event:
        pclintline.info = pclintline.info + linetemp
        continue

'''
styles = {'datetime': xlwt.easyxf(num_format_str='yyyy-mm-dd hh:mm:ss'),
          'date': xlwt.easyxf(num_format_str='yyyy-mm-dd'),
          'time': xlwt.easyxf(num_format_str='hh:mm:ss'),
          'header': xlwt.easyxf('font: name Times New Roman, color-index black, bold on', num_format_str='#,##0.00'),
          'default': xlwt.Style.default_style}


读写2003,可能由于字符串太长还是一些特殊字符的影响，导致2003有些显示不出来，所以换成是2007
wb = xlwt.Workbook(encoding = 'utf-8')
sheet = wb.add_sheet(u'pclint')
for num,eachitem in enumerate(pclintlist):
    row = num
    sheet.write(row,0, str(eachitem.Event))
    sheet.write(row,1, str(eachitem.info))
    check_result.write('错误内容' + eachitem.Event + '文件' + eachitem.info + '\n')
wb.save('pclint.xls')
'''

wb = Workbook()
ws = wb.active
for num,eachitem in enumerate(pclintlist):
    eachitem.type = re.findall(r'(?:Warning|Error) \d+',eachitem.info)
    for eachtype in eachitem.type:
        ws.append([eachtype, ' ' + str(eachitem.Event), eachitem.info])
    check_result.write('错误内容' + eachitem.Event + '文件' + eachitem.info + '\n')
wb.save("pclint.xlsx")

check_result.close()
check_errLine.close()