#!/bin/bash
#This script uses rwho and other system routines to check the state of
#a cluster's nodes over a local network.  It provides information about the number of
#processes launched at each node and the currently used RAM.

red='\033[01;31m'

num=$(ls /var/spool/rwho/* | wc -l)

for i in `seq 1 1 $num`; do
    RUP="$(/usr/bin/ruptime | head -n $i | tail -n 1)"
    name=$(echo $RUP | awk '{print $1}')
    status=$(echo $RUP | awk '{print $2}')
    timeup=$(echo $RUP | awk '{print $3}')
    load1=$(echo $RUP | awk '{print $7}')
    load2=$(echo $RUP | awk '{print $8}')
    load3=$(echo $RUP | awk '{print $9}')
    if [[ $status == "up" ]]
    then
    #_CMD="ssh $name"
    _CMD="rsh $name"
    ram="$($_CMD free -hmt | grep Mem: -A 1 )"
    rtotalram="$(echo $ram | awk '{ print $2 }')"
    usedram="$(echo $ram | awk '{ print $10 }')"
    else
      usedram=""
      rfreeram=""
      rtotalram=""
    fi
    echo "$RUP    Max load=16   Used RAM: $usedram of $rtotalram"
done

#Uncomment this to provide some warning to the users.
#printf "\n"
#echo -e "${red}Next stop 15-06-2015 at 10:00${NC}"
