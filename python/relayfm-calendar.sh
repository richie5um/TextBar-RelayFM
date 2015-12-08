#!/bin/bash

CURRENT_TIMEZONE=`date +%Z`

CALENDAR_URL_HTML='https://www.google.com/calendar/htmlembed?showTitle=0&showPrint=0&showTabs=0&showCalendars=0&mode=AGENDA&height=600&wkst=1&bgcolor=%23FFFFFF&src=relay.fm_t9pnsv6j91a3ra7o8l13cb9q3o@group.calendar.google.com&color=%23182C57&ctz='$CURRENT_TIMEZONE

# get the whole HTML, and reformat it with `tidy` and process it with python script
curl -sfL "$CALENDAR_URL_HTML" \
| tidy \
    --char-encoding utf8 \
    --wrap 0 \
    --show-errors 0 \
    --indent yes \
    --input-xml no \
    --output-xml no \
    --quote-nbsp no \
    --show-warnings no \
    --uppercase-attributes no \
    --uppercase-tags no \
    --clean yes \
    --force-output yes \
    --join-classes yes \
    --join-styles yes \
    --markup yes \
    --output-xhtml yes \
    --quiet yes \
    --quote-ampersand yes \
    --quote-marks yes \
| python relayfm-calendar.py