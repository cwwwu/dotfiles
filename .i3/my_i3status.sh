#!/bin/bash

# append i3status output to current weather
# the quote and escape magic is required to get valid
# JSON output, which is expected by i3bar (if you want
# colors, that is. Otherwise plain text would be fine).
# For colors, your i3status.conf should contain:
# general {
#   output_format = i3bar
# }

# i3 config looks like this:
# bar {
#   status_command <path to this script>
# }

i3status --config ~/.i3/i3status.conf | (read line && echo $line && read line && echo $line && while :
do
  read line
  net_throughput=$(~/.i3/measure-net-speed.bash)
  net_throughput="{\"name\":\"net_speed\",\"full_text\":\"${net_throughput}\",\"color\":\""#00FF00"\"},"
  current_weather=$(curl -s http://weather.gc.ca/rss/city/on-82_e.xml | awk -F "[><]" '/Current Conditions:/{gsub("Current Conditions: ",""); gsub("&#xB0;","\xC2\xB0"); print $3}')
  current_weather="{\"name\":\"weather\",\"full_text\":\"${current_weather}\",\"color\":\""#0066CC"\"},"
  echo "${line/[/[$current_weather $net_throughput}" || exit 1
done)

