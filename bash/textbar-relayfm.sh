#!/bin/bash
# Purpose: show the on-air status of Relay.fm
#
# From:    Tj Luo.ma
# Mail:    luomat at gmail dot com
# Web:     http://RhymesWithDiploma.com
# Date:    2015-04-30
# Modifications: Rich Somerfield (2015-10-27 : To run in bash, originally written for ZSH).

NAME="$0:t:r"

# Check the 'live' web page and grab the <title> from the HTML
RELAY_STATUS=`curl -sfL 'http://www.relay.fm/live' \
    | fgrep -i '<title>' \
    | sed 's#<title>##g ; s#</title>##g'`

case "$RELAY_STATUS" in
    On-Air*)

        # Extract the show title minus the word “On-Air: ”
        SHOW_TITLE=`echo "$RELAY_STATUS" | sed 's#On-Air: ##g' `

        # If we don't get a show title for some reason, use something else
        [[ "$SHOW_TITLE" == "" ]] && SHOW_TITLE="Relay FM is live"

        # Output the information to stdout
        echo "🎣 $SHOW_TITLE"

        echo "Go to relay.fm"

        exit 0
    ;;

    *)
        # OK, if there's no show on right now,
        # then tell me when the _next_ show is
        # by parsing Relay’s Google calendar

        FILE="${TMPDIR-/tmp/}relayfm.$RANDOM.html"

        PREVIOUS="${TMPDIR-/tmp/}relayfm.previous.html"

        CURRENT_TIMEZONE=`date +%Z`

        CALENDAR_URL_HTML='https://www.google.com/calendar/htmlembed?showTitle=0&showPrint=0&showTabs=0&showCalendars=0&mode=AGENDA&height=600&wkst=1&bgcolor=%23FFFFFF&src=relay.fm_t9pnsv6j91a3ra7o8l13cb9q3o@group.calendar.google.com&color=%23182C57&ctz='$CURRENT_TIMEZONE

        # get the whole HTML, and reformat it with `tidy` and save it to a local file we can parse
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
            --quote-marks yes > "$FILE"

        # if the file is not longer than 0 bytes, we didn't get the info we need
        # so re-use the previous info
        if [[ ! -s "$FILE" ]]
        then

            if [ -s "$PREVIOUS" ]
            then
                # if a previous file exists, use it
                # take the first line
                # but truncate it after 50 characters
                # just in case it's full of junk
                head -1 "$PREVIOUS" | colrm 50-

                exit 0

            else
                # if a previous file doesn't exist
                # or is 0 bytes, just give an error
                echo "Relay FM Error"

                exit 0
            fi
        fi

        # look for the 'event-summary' as a span (important!) and then take the first one, and remove the HTML
        SHOW_TITLE=`fgrep -A1 '<span class="event-summary">' "$FILE" | head -1 | sed 's#</span></a>##; s#.*>##g'`

        # Make an ARRAY out of the date info
        # we get something like
        #           Fri May 1, 2015
        # but we only _need_ the Month and DayOfMonth
        # and strip any leading spaces or tabs
        SHOW_DATE=($(fgrep -A1 '<div class="date">' "$FILE" | head -2 | tail -1 | sed 's#^[     ]*##g'))

        # Get the time and strip any leading spaces or tabs
        SHOW_TIME=`fgrep -A1 '<td class="event-time">' "$FILE" | head -2 | tail -1 | sed 's#^[     ]*##g'`

        # This will give us the month as letters.
        MONTH="${SHOW_DATE[2]}"

        # Get the number, remove the comma
        DAY_OF_MONTH=`echo "${SHOW_DATE[1]}" | tr -d ','`

        # now get today's month/date (strip leading zeros from the day)
        TODAYS_DATE=`date '+%b %d' | sed 's# 0*# #g'`

        if [[ "$TODAYS_DATE" == "$MONTH $DAY_OF_MONTH" ]]
        then
            # The next show is today, just show time
            echo "$SHOW_TITLE ($SHOW_TIME)" | tee "$PREVIOUS"

        else
            # Output the show title, month/day @ time)
            echo "$SHOW_TITLE ($MONTH $DAY_OF_MONTH @ $SHOW_TIME)" | tee "$PREVIOUS"
        fi

        echo "Go to relay.fm"
    ;;

esac

exit 0
