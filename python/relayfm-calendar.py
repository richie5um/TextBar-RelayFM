import sys
from datetime import datetime

try:
    import xml.etree.cElementTree as ET
except ImportError:
    import xml.etree.ElementTree as ET

html_str = sys.stdin.read()

tree = ET.fromstring(html_str)
for elem in tree.iterfind(".//{http://www.w3.org/1999/xhtml}div[@class='view-container-border view-container']"):
	for day in elem:
		eventDate = day.findtext(".//{http://www.w3.org/1999/xhtml}div[@class='date']")
		eventDate = eventDate.strip()
		for event in day.iterfind(".//{http://www.w3.org/1999/xhtml}tr[@class='event']"):			
			eventTime = event.findtext(".//{http://www.w3.org/1999/xhtml}td[@class='event-time']")
			eventTime = eventTime.strip()
			
			eventName = event.findtext(".//{http://www.w3.org/1999/xhtml}span[@class='event-summary']")
			eventName = eventName.strip()
			
			eventDateTimeString = '{} {}'.format(eventDate, eventTime)
			eventDateTime = datetime.strptime(eventDateTimeString, '%a %d %b %Y %H:%M')

			if eventDateTime.date() > datetime.today().date():
				print eventDate, eventTime, eventName