# Commands
function notify_ips {
  mars_message_ips=/tmp/mars_message_ips
  echo -e "Hostname: *$(hostname)*\nPrivate IPs:" >> $mars_message_ips
  echo -e "$(ifconfig | grep -i mask | awk '{print "- "$2}')" >> $mars_message_ips

  echo -e "\nPublic IP:" >> $mars_message_ips
  echo -e "- $(curl -s ifconfig.me)" >> $mars_message_ips


  curl -s https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
    -F chat_id=$CHAT_ID \
    -F parse_mode="Markdown" \
    -F text="$(cat $mars_message_ips)" \
    > /dev/null

  rm -f $mars_message_ips
}

function notify_down {
  mars_message_down=/tmp/mars_message_down
  echo -e "Hostname: *$(hostname)*\n" >> $mars_message_down
  echo -e "System Shutdown\n$(date)" >> $mars_message_down

  curl -s https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
    -F chat_id=$CHAT_ID \
    -F parse_mode="Markdown" \
    -F text="$(cat $mars_message_down)" \
    > /dev/null

  rm -f $mars_message_down
}

function monitor_check {
  mars_report=/tmp/mars-report.txt
  cpu_usage=$(echo $[100-$(vmstat 1 2|tail -1|awk '{print $15}')])
  mem=$(free -m)
  mem_usage=$(echo "$mem" | awk 'NR==2{printf "%i\n", ($3*100/$2)}')

  if [ $cpu_usage -ge $CPU_TRESHOLD ] || [ $mem_usage -gt $MEM_THRESHOLD ]
  then
    echo -e "$(hostname) Resources Alert $(date +"%Y%M%d %T")\n" > $mars_report
    top -b -o +%CPU -e g -E g -H -c | head -n 20  >> $mars_report
    caption=$(echo -e "Hostname: *$(hostname)*\nHigh Resource Usage:\nRAM: $mem_usage%  |  CPU: $cpu_usage%")

    curl -s https://api.telegram.org/bot$BOT_TOKEN/sendDocument \
    -F chat_id=$CHAT_ID \
    -F parse_mode="Markdown" \
    -F document=@$mars_report \
    -F caption="$caption" \
    > /dev/null

    rm -f $mars_report
  fi
}

case "$1" in
  ips)
    notify_ips
  ;;
  monitor)
    monitor_check
  ;;
  down)
    notify_down
  ;;
  *)
    echo "Invalid Action"
    exit 1
  ;;
esac

exit 0
