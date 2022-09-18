#!/bin/bash
# Analyze the ram and cpu usage of a process in real time.
# written by Alfio Salanitri <www.alfiosalanitri.it> and are licensed under MIT license. 

display_help() {
cat << EOF
Copyright (C) 2022 by Alfio Salanitri
Website: https://github.com/alfiosalanitri/process-analyzer
Usage: $(basename $0) -n 5
Options

-n, --interval seconds  
    Specify update interval. The command will not allow quicker than 1 second interval 

-h, --help  
    show this help
-------------
EOF
exit 0
}

# display memory and ram used
analyze_me() {
 ps -p $1 -o size,%cpu,cmd | tail -n 1 | awk '{ram=$1/1024;cpu=$2;name=$3;printf "Name: [%s] - RAM: [%5.2f Mb] - CPU: [%5.2f%]\n", name, ram, cpu}'
}

# inteval seconds
interval=.1
pid='search'
# check user options
while [ $# -gt 0 ] ; do
  case $1 in
    -h | --help) display_help ;;
    -n | --interval)
      if ! [[ $2 =~ ^[0-9]+$ ]] ; then
        echo "Interval must be an integear."
        exit 1
      fi
      if [ $2 -gt 1 ]; then
        interval=$2
      fi
    ;;
  esac
  shift
done

# get process name
read -p "Type the process name: "
pid=$(pidof -s "$REPLY")
if [ "" == "$pid" ]; then
  echo "Sorry, but this process doesn't exists. Try again."
  exit 1
fi

# start
echo "-----------------"
echo "Process Analyzer"
echo "-----------------"
echo "press CTRL+C to exit"
echo ""
while true; do
  usage=$(analyze_me $pid)
  echo -n -e "$(date) | $usage\r"
  sleep $interval
done
exit 0
