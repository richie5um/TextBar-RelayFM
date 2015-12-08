# curl 'https://www.google.com/calendar/htmlembed?showTitle=0&showPrint=0&showTabs=0&showCalendars=0&mode=AGENDA&height=600&wkst=1&bgcolor=%23FFFFFF&src=relay.fm_t9pnsv6j91a3ra7o8l13cb9q3o@group.calendar.google.com&color=%23182C57&ctz=' -sfL | tr -d '\n' | python relayfm-calendar.py

import re, sys

p = re.compile(ur'<div class=\"date-section[^>]+[>][^>]+[>](?P<date>[^<]+).*?(class="events".*?"event-time">(?P<time>[^<]+))+')
test_str = sys.stdin.read()
matches = re.findall(p, test_str)

print matches

# for match in matches:
# 	print "{0} [{1}]".format(match[0], match[1])
	
# target = open('/tmp/relayfm.shows.actions', 'w')
# for match in matches:
# 	target.write("{0}\n".format(match[2]))
