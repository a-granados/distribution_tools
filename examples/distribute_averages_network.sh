#!/bin/bash

#Split data files into pieces to compute averages in parallel in a
#cluster.

#This is not working yet. 

clientsfile="nodeslist"
datafile1="periods_ij.tmp"
datafile2="orbit.tna"

numnodes=$(cat $clientsfile | wc -l)
numprocs=0
for i in `seq 1 1 $numnodes`;do
	tmp=$(tail -n +$i $clientsfile | head -n 1 | awk '{print $2}')
	let numprocs=$numprocs+$tmp
done

totaldata=$(cat $datafile1 | wc -l)
numdatadis=$(( $totaldata / $numprocs ))

exit

split ....
for i in `seq 1 1 $numnodes`;do
	actualnode=$(tail -n +$i $nodesfile | head -n 1 | awk '{print $1}')
	numprocs=$(tail -n +$i $clientsfile | head -n 1 | awk '{print $2}')
	for j in `seq 1 1 $numprocs`;do
	ssh $actualnode "./post_process .... "
	done
done

