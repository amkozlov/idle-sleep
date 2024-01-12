#!/bin/bash

sleepafter=3600
activefile=/tmp/ecosleep-last-active
mintty=1

function yes_or_no {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}

function is_active {
  NTTY=`w -h | wc -l`
  L1=`cut -d" " -f1 /proc/loadavg`
  LMIN=0.5

  if [ $NTTY -gt $mintty ]; then
    return 1;
  elif  (( $(bc <<<"$L1 > $LMIN") )); then
    return 2;
  else
    return 0;
  fi
}

function parse_delay {
  if [[ $1 =~ [0-9]+h ]]; then
    delay_unit=3600
  elif [[ $1 =~ [0-9]+m ]]; then
    delay_unit=60
  elif [[ $1 =~ [0-9]+d ]]; then
    delay_unit=86400
  elif [[ $1 =~ [0-9]+ ]]; then
    delay_unit=1
  else
    echo "Invalid delay: $1"
    exit
  fi
  delay_num="${1/[hmd]/}"
  let "delay_out = $delay_num * $delay_unit"
#  echo $delay_out
}

mode=${1:-"now"}
delay=0
confirm=0

#echo "$mode"

if [ "$mode" == "auto" ]; then
  mintty=0
  tsnow=`date +"%s"`
  if [ -f $activefile ]; then
    oldactive=`cat $activefile`
  else
    oldactive=$tsnow
    echo $tsnow > $activefile
  fi
#  echo "$oldactive $tsnow"
  if [ $oldactive -gt $tsnow ]; then
    echo "Sleep inhibitor enabled"
    exit
  else
    sleepafter=${2:-$sleepafter}
    is_active
    state=$?
    if [ $state -eq 0 ]; then
      # idle state, check timeout
      let "idletime = $tsnow - $oldactive"
      echo "idle time: $idletime / $sleepafter"
      if [ $idletime -gt $sleepafter ]; then
        rm $activefile
        systemctl poweroff
      fi
    else
      # active state -> update timestamp 
      echo "not idle"
      echo $tsnow > $activefile
    fi
  fi
  exit
elif [ "$mode" == "status" ]; then
  tsnow=`date +"%s"`
  if [ -f $activefile ]; then
    tsuntil=`cat $activefile`
  else
    tsuntil=$tsnow
  fi
  if [ $tsuntil -gt $tsnow ]; then
    untilstr=`date -d @$tsuntil`
    echo "EcoSleep disabled until: $untilstr"
  else
    echo "EcoSleep enabled"
  fi
  exit  
elif [ "$mode" == "disable" ] || [ "$mode" == "off" ]; then
  delay=${2:-"8h"}
  parse_delay $delay
  delay=$delay_out
  tsnow=`date +"%s"`
  let "tsuntil = $tsnow + $delay"
  echo $tsuntil > $activefile
  untilstr=`date -d @$tsuntil`
  echo "Server will not be powered off until: $untilstr"
  exit
elif [ "$mode" == "enable" ] || [ "$mode" == "on" ]; then
  date +"%s" > $activefile
  exit
elif [ "$mode" == "now" ]; then
  confirm=1
else
  delay=$mode  
fi

parse_delay $delay
delay=$delay_out

if [ $delay -gt 0 ]; then
  echo "WARNING: Server will be powered off in $delay seconds!"
  sleep $delay
fi

is_active
state=$?

if [ $state -eq 1 ]; then
   echo "ERROR: Active sessions found!"
   exit
elif [ $state -eq 2 ]; then
   echo "ERROR: CPU utilization is above 50%, check for processes running in backgound!"
   exit   
else	

  if [ $confirm -eq 1 ]; then
    message="This server will be switched off now. Are you sure?"

    yes_or_no "$message" && rm $activefile && systemctl poweroff
  else
    rm $activefile
    systemctl poweroff
  fi  
fi
