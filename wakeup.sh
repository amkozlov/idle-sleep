#!/bin/bash
host=$1
user=ipmiop

scriptdir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
hostfile=$scriptdir/hostfile

# You might want to restrict access to this file, since IPMI operator can also do power off etc. :)  
pwdfile=$scriptdir/ipmiop.txt

iface=
while IFS=' ' read -r h i;
do

  if [ "$h" == "$host" ]; then
    iface=$i
    break
  fi

done < "$hostfile"

if [ -z $iface ]; then
  echo "Unknown host: $host"
  exit
fi

#echo "$host $iface"

ipmitool -I lanplus -H $iface -U $user -f $pwdfile -L OPERATOR power on

printf "%s" "Waiting for $host ..."
while ! ping -c 1 -n -w 1 $host &> /dev/null
do
    printf "%c" "."
    sleep 1
done

printf "\n%s\n"  "Server is back online!"
