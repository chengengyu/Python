from splinter import Browser
import datetime

htmlDir = r'K:\\work\\GitHub\\Python\\autoweb\\会议室预定系统.html'

config1 = [\
    {\
        'room': '702',\
        'startTime': '10:30 AM',\
        'endTime': '11:30 AM',\
        'text': 'tl'\
    },\
    {\
        'room': '701',\
        'startTime': '9:30 AM',\
        'endTime': '10:30 AM',\
        'text': 'lh'\
    }\
]

config2 = []
config3 = [\
    {\
        'room': '702',\
        'startTime': '10:30 AM',\
        'endTime': '11:30 AM',\
        'text': 'lh'\
    }\
]
config4 = []
config5 = [\
    {\
        'room': '702',\
        'startTime': '10:30 AM',\
        'endTime': '11:30 AM',\
        'text': 'pmr'\
    }\
]
config6 = []
config7 = []

dateConfig = [config1, config2, config3, config1, config5, config6, config7]

'''
	<option value="701">A402室</option>
	<option value="702">407室</option>
	<option value="704">415室</option>
	<option value="705">409室</option>
	<option value="706">盛地101室</option>
	<option value="701">A402室</option>
	<option value="702">407室</option>
	<option value="704">415室</option>
	<option value="705">409室</option>
	<option value="706">盛地101室</option>
	<option value="701">A402室</option>
	<option value="702">407室</option>
	<option value="704">415室</option>
	<option value="705">409室</option>
	<option value="706">盛地101室</option>
	<option value="701">A402室</option>
	<option value="702">407室</option>
	<option value="704">415室</option>
	<option value="705">409室</option>
	<option value="706">盛地101室</option>
'''

def getDate():
    today = datetime.datetime.now()
    detal = datetime.timedelta(days=7)
    roomDay = today + detal
    return roomDay

def setHtml(roomDay, config):
    b = Browser(driver_name='chrome')
    url = htmlDir
    b.visit(url)
    b.select('selLocation', config['room'])
    b.fill('textDescription', config['text'])
    b.select('selStartMonth', roomDay.month)
    b.select('selStartDay', roomDay.day)
    b.select('selStartTime', config['startTime'])
    b.select('selEndTime', config['endTime'])
    #b.click_link_by_id('submit')

if __name__ =="__main__":
    roomDay = getDate()
    configList = dateConfig[roomDay.weekday()]
    if configList:
        print(configList)
        for config in configList:
            setHtml(roomDay, config)
        input("wait")
    else:
        print("null")
