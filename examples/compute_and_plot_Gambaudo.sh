#!/bin/bash
#This script is used to check Gambaudo's conditions. It needs
#period.tna computed a priori. Then, for a range of values of 1/A we
#launch "checking_Gambaudo_conditions" and plot the periods and the
#sets.
#This scripts launches some computations and the plots them using
#gnuplt. The plots are frames of a video. Use the script "rename.sh"
#to rename the file names to be later used with aviconf or similar to
#make a video from them.

Aini=0.2
Afin=0.6
d=0.5
ncores=4
numpoints=100
pltfile=work_Gambaudo.plt #gnuplt script
prefixpic=regions-orbits #Prefix for the frames

Ah=$(echo "scale=8; ($Afin-$Aini)/($numpoints)" | bc)

for i in `seq 1 1 $numpoints`; do
	A=$(echo "scale=8; $Aini+($i-1)*$Ah" | bc)
	sleep 1s
	echo $i $A
	gnuplprocs=$(ps -C gnuplot -o pid --no-headers | wc -l | tr -d " ")
	mainprocs=$(ps -C checking_Gambaudo_conditions -o pid --no-headers | wc -l | tr -d " ")
	let totalprocs=$gnuplrocs+$mainprocs
	while [ $totalprocs -ge $ncores ];do
		sleep 0.1s
		gnuplprocs=$(ps -C gnuplot -o pid --no-headers | wc -l | tr -d " ")
		mainprocs=$(ps -C checking_Gambaudo_conditions -o pid --no-headers | wc -l | tr -d " ")
		let totalprocs=$gnuplprocs+$mainprocs
	done
	if (( $(echo "$A > 0.217" | bc -l) )) && (( $(echo "$A<0.5475" | bc -l) )); then
	period=2
	else
	  period=1
	fi
	#period=2
	(
	./checking_Gambaudo_conditions $A $period > "output$i.tna"
	sed -e "$(echo /set output/c\set output \"tmp~/regions-orbits$i.jpg\")" "$pltfile" > "$pltfile$i.aux1"
	sed -e "$(echo /file=/c\file=\"output$i.tna\")" "$pltfile$i.aux1" > "$pltfile$i.aux2"
	sed -e "$(echo /A=/c\A=$A)" "$pltfile$i.aux2" > "$pltfile$i.aux3"
	mv -f "$pltfile$i.aux3" "$pltfile$i.plt"
	gnuplot "$pltfile$i.plt"
	rm -f $pltfile$i*
	rm "output$i.tna"
	)&
done
