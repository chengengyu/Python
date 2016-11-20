__author__ = 'chengengyu'


import os, codecs
import re
import xlwt
from os.path import join, getsize


file = open('coverrity_chengengyu.TXT','r')
wb = xlwt.Workbook(encoding = 'utf-8')
sheet = wb.add_sheet(u'函数')
row = 0
linenum = 0
for num,eachline in enumerate(file):
    if (num % 8 ) == 0:
        linenum = 0
        row = row + 1
    sheet.write(row,linenum, eachline)
    linenum = linenum + 1
wb.save('conver.xls')
