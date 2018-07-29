import win32api, win32con
import os

fileName = '1.txt'

win32api.SetFileAttributes(fileName, win32con.FILE_ATTRIBUTE_READONLY)
try:
    os.remove(fileName)
except:
    print('cannot remove')
win32api.SetFileAttributes(fileName, win32con.FILE_ATTRIBUTE_NORMAL)
os.remove(fileName)