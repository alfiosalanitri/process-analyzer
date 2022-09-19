#!/bin/bash
# Analyze the ram and cpu usage of a process in real time.
# written by Alfio Salanitri <www.alfiosalanitri.it> and are licensed under MIT license. 

display_help() {
cat << EOF
Copyright (C) 2022 by Alfio Salanitri
Website: https://github.com/alfiosalanitri/process-analyzer
Usage: $(basename $0) -n 5 -p 1500
Options
-p, --process (optional)
    Specify process id number.        

-n, --interval (optional)
    Specify update interval. The command will not allow quicker than 1 second interval 

-h, --help  
    show this help
-------------
EOF
exit 0
}

# display memory and ram used
analyze_me() {
  ps -p $1 -o size,%cpu,cmd | tail -n 1 | awk '{ram=$1/1024;cpu=$2;name=$3;printf "Name: [...%s] - RAM: [%5.2f Mb] - CPU: [%5.2f%]\n", substr(name, length(name)-15), ram, cpu}'
}

# check if given number is an integear
is_integear() {
  if ! [[ $1 =~ ^[0-9]+$ ]] ; then
    echo "Interval must be an integear."
    exit 1
  fi
}

# interval seconds
interval=.1
# default pid is auto. User must be type the name on cli
pid='auto'

# check user options
while [ $# -gt 0 ] ; do
  case $1 in
    -h | --help) display_help ;;
    -n | --interval)
      is_integear $2
      if [ $2 -gt 1 ]; then
        interval=$2
      fi
      ;;
    -p | --process)
      is_integear $2
      pid=$2
      ;;
  esac
  shift
done

# get process name from cli
if [ "auto" == "$pid" ]; then
  read -p "Type the process name: "
  readarray -t pid_list <<<"$(pgrep -a "$REPLY")"
  pid_list_tot="${#pid_list[@]}"
  if [ $pid_list_tot -gt 1 ]; then
    echo "Choose the process to use:"
    echo ""
    PS3='Type the choice number: '
    select pid_number in "${pid_list[@]}"; do
      pid=$(echo $pid_number | awk '{print $1}')
      if ! [ "$REPLY" -eq "$REPLY" ] 2>/dev/null; then
        echo "$REPLY must be an integear. Try again"
        exit 1
      fi
      if [ $REPLY -eq 0 ] || [ $REPLY -gt ${#pid_list[@]} ]; then
        echo "$REPLY isn't a valid option. Try again"
        exit 1
      fi
      break
    done
  else
    pid=$(echo ${pid_list[0]} | awk '{print $1}')
  fi
fi

# validate pid id again.
is_integear $pid
# start
echo "----------------------------------"
echo "Process Analyzer for PID $pid"
echo "update every $interval sec"
echo "----------------------------------"
echo "Press <CTRL+C> to exit"
echo ""
while true; do
  usage=$(analyze_me $pid)
  echo -n -e "$(date) | $usage\r"
  sleep $interval
done
exit 0
