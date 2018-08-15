from splinter import Browser
import datetime

htmlDir = r'K:\\work\\GitHub\\Python\\考勤抓取\\大唐移动考勤请假管理系统.html'

def getHref (browser):
    hrefList = []
    elementList = browser.find_link_by_partial_text('查看')
    for ele in elementList:
        print(ele['href'])
        hrefList.append(ele['href'])
    nextHref = b.find_link_by_partial_text('下一页')
    if nextHref:
        nextHref[0].click()
        hrefList = hrefList + getHref(browser)
    return hrefList

b = Browser(driver_name='chrome')
url = htmlDir
b.visit(url)
hrefList = getHref(b)
print(len(hrefList))
b.visit(hrefList[0])


#if __name__ =="__main__":



