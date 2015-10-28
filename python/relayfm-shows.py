# curl 'http://www.relay.fm/master/feed' | tr -d '\n' | python -m relayfm-shows.py

import re, sys

p = re.compile(ur'<item>.*?<title>(?P<title>.*?)<\/title>.*?<pubDate>(?P<date>.*?)<\/pubDate>.*?<link>(?P<link>.*?)<\/link>.*?<\/item>')
test_str = sys.stdin.read()
matches = re.findall(p, test_str)

for match in matches:
	print "{0} [{1}]".format(match[0], match[1])
	
target = open('/tmp/relayfm.shows.actions', 'w')
for match in matches:
	target.write("{0}\n".format(match[2]))
