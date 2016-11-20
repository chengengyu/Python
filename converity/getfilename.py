__author__ = 'chengengyu'


import os, codecs
import re
import xlwt
from os.path import join, getsize


file = open('file_rrc.TXT','r')
wb = xlwt.Workbook(encoding = 'utf-8')
sheet = wb.add_sheet(u'函数')
row = 0
linenum = 0
for num,eachline in enumerate(file):
    ser = re.search(r'Src.*/(.*\.c)$', eachline)
    if ser :
        sheet.write(row,0, ser.group(1))
        row = row + 1
wb.save('file_rrc.xls')
