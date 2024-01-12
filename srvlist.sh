#!/bin/bash
usr=pwrmon
passw=pwrmonPass

scriptdir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
hostfile=$scriptdir/hostfile

while IFS=' ' read -r host iface;
do

  #echo "$host $iface"

  state=`ipmitool -I lanplus -H $iface -U $usr -P $passw -L USER power status | grep -c "Power is on"`

  printf "%-12s" "$host"
  if [ "$state" -eq "1" ]; then
    echo "ON"
  else
    echo "OFF"
  fi

done < "$hostfile"

