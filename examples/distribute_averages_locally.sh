#!/bin/bash

#This is to distribute the post_process computation in a local machine

#Number of lines per each output file (script input)
numlines=$1
numprocesses=$2

rm orbit_tmp* periods_tmp*
split -d -l $numlines orbit.tna orbit_tmp
#split -d -l $numlines periods_ij.tmp periods_tmp
split -d -l $numlines period.tna periods_tmp
#split -d -l $numlines period.tna periods_tmp

numfiles=$(ls orbit_tmp* | wc -l)

for i in `seq 1 1 $numfiles`; do
	orbitfile=$(ls orbit_tmp* | head -n $i | tail -n 1)
	periodsfile=$(ls periods_tmp* | head -n $i | tail -n 1)
echo "$periodsfile $orbitfile"
	#./kill_one_resn.sh && ./post_process $periodsfile $orbitfile > averages_tmp$i && nice -n 0 resn&
	./post_process $periodsfile $orbitfile > averages_tmp$i &
	sleep 0.5s
done
