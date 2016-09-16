#!/bin/bash

#This is a general purpose script to parameterized-like distribution. In other words, it
#executes a certain program for number of different paramter values.
#The general call of the program to be launched is given in "crida" function, and, for this example,
#parameter x is varied.
#The instances are launched trhough the network to a set of clients stored in the clientlist file.
#At each client the script launches as many instances as given in the second column of the clientlist file
#(probably the number of cpu's of that client). The third column indicates the "niceness" to be used
#when launched. This sets the priority that the system will give to that particular process. Defaults
#nice value is 0, although this can vary depending on the linux version. Lowest priority is usually 19.
#This means that, if you use this latter value, other instances launche by 
#other users or yourself will have priority.
#Ideally, the user home folder should be shared by all clients in the clientlist,
#either using nfs or samba or whatever.

#What the script does?
# Every 20 seconds tt logs into the clients. For each client it counts the number of running instances.
#If it is smaller that the corresponding second column (nprocess variable), then it launches
#as many new instances as necessary to reach this value. When this is reached, the script checkes the next client.



function crida(){
##Exemple:
#Example: the program gets as input the parameter x, which is varied,
#and its output is written in a file. 
ssh $actualclient "cd $datadir && nice -n $niceness ./$program $x  > outputfile_$i.txt"</dev/null
}

i=1

program=gp ##Name of the program. Try to avoid common names like "main" or program, to avoid coincidence with other users.
datadir=`pwd` ##The current directory will be the working one.
clientfile=$HOME/clientlist ##Mus be located in yor home directory
clientfiletmp=clientslist_tmp
precisio=10 #Number of digits to be used by the script.
x0=0.1 #First value
xf=10 #Last value
numpoints=1000
hx=$(echo "scale=$precisio;($xf - $x0)/$numpoints " | bc) 


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
			x=$(echo "scale=$precisio; $x0+($i-1)*$hx" | bc)
#========================================================================
		(
                pids=$(ssh $actualclient "ps -C $programa -o pid --no-headers")
                while [ `echo $?` -ne 0 ]; do
			sleep 1s
                        pids=$(ssh $actualclient "ps -C $programa -o pid --no-headers")
                done
                ##This is for checking purposes:
                #echo "In node $actualclient there are currently $pids processes before launching process number $i"
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
		###To quit the loop:
		actcliproc=$nprocess
		fi
	done

	done
done


rm $clientstmp
