#!/bin/bash

# ps -C gp -o pid,ruser=atamarit --no-headers --sort -time

function crida(){
##Exemple:
#Example: the program gets as input the parameter x, which is varied,
#and its output is written in a file. 
ssh $actualclient "cd $datadir && nice -n $niceness ./$program $x  > outputfile_$i.txt"</dev/null
}

i=1
numpoints=19

programa=gp ##Name of the program. Try to avoid common names like "main" or program, to avoid coincidence with other users.
datadir=`pwd` ##The current directory will be the working one.
clientfile=$HOME/clientlist ##Mus be located in yor home directory
clientfiletmp=clientslist_tmp
precisio=10 #Number of digits to be used by the script.


while [ $i -le $numpoints ]; do
	cat $clientfile | grep "^[^#]"> $clientfiletmp ## Commented clients will be ingored.
	numclients=$(cat $clientfiletmp | wc -l)
	sleep 20s
	for j in `seq 1 1 $numclients`;do
		actualclient=$(tail -n +$j $clientfiletmp | head -n 1 | awk '{print $1}')
		nprocess=$(tail -n +$j $clientfiletmp | head -n 1 | awk '{print $2}')
		niceness=$(tail -n +$j $clientfiletmp | head -n 1 | awk '{print $3}')
		actcliproc=$(ssh $actualclient "ps -C $programa -o pid --no-headers | wc -l"</dev/null)
	while [ `echo $?` -ne 0 ]; do
		sleep 1s
		actcliproc=$(ssh $actualclient "ps -C $programa -o pid --no-headers | wc -l "</dev/null)
	done
	while [ $actcliproc -lt $nprocess ]; do
		if [ $i -le $numpoints ]; then
##======================================================================
#Computation of the next value of x
#			x=$(echo "scale=$precisio; $x0+($i-1)*$hx" | bc)
#========================================================================
		(
                pids=$(ssh $actualclient "ps -C $programa -o pid --no-headers")
                while [ `echo $?` -ne 0 ]; do
			sleep 1s
                        pids=$(ssh $actualclient "ps -C $programa -o pid --no-headers")
                done
                #echo "en el node $actualclient  abans de tirar el proces $i hi ha els pids: $pids"
		crida
                while [ `echo $?` -ne 0 ]; do
			sleep 1s
			crida
		done
                pids=$(ssh $actualclient "ps -C $programa -o pid --no-headers")
                while [ `echo $?` -ne 0 ]; do
			sleep 1s
                        pids=$(ssh $actualclient "ps -C $programa -o pid --no-headers")
                done
                echo "en el node $actualclient  despres de tirar el proces $i pids: $pids"

		)&
		sleep 1s
		let i=$i+1
		actcliproc=$(ssh $actualclient "ps -C $programa -o pid --no-headers | wc -l "</dev/null)
		while [ `echo $?` -ne 0 ]; do
			sleep 1s
			actcliproc=$(ssh $actualclient "ps -C $programa -o pid --no-headers | wc -l "</dev/null)
		done
		else
		###Per sortir del loop
		actcliproc=$nprocess
		fi
	done

	done
done


rm $clientstmp
