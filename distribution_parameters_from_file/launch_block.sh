#/bin/bash
#This scripts launches computations. The computing programs take as
#inputs certain values that are writen in a file. The scripts takes as
#input the first and last lines of that file for which the computations
#will be launched. After each computation, a gnnuplot script is properly
#modified to plot  the results.
#These computations can be distributed for multicore by the script
#distribute_from_file.sh


epsini=$(cat system_parameters.dat | awk '{print $5}')


datafile=fixed_points.dat.tmp
numiterates=10
pltfile=work_Av.plt

for i in `seq $1 1 $2`;do
	#Reading parameters from datafile:
	lambda=$( tail -n +$i $datafile | head -n 1 | awk '{print $1}')
	x0=$( tail -n +$i $datafile | head -n 1 | awk '{print $2}')
	y0=$( tail -n +$i $datafile | head -n 1 | awk '{print $3}')
	t=$( tail -n +$i $datafile | head -n 1 | awk '{print $4}')
	numiterates=$(echo "scale=5; 2*$t/6.28" | bc)
	#Launching computations:
	./plot_trajectory $x0 $y0 $numiterates $lambda > po$i.dat
	./stroboscopic_map_OS $x0 $y0 3000 $lambda > po_OS$i.dat
	./stroboscopic_map_k2S $x0 $y0 3000 $lambda > po_k2S$i.dat
	##Modifying the gnuplot scripts:
	framename=$(printf "po_%0.6d.jpg" $i)
	sed -e "$(echo /set output/c\set output \"$framename\")" "$pltfile" > "$pltfile$i.aux1"
	sed -e "$(echo /file=/c\file=\"po$i.dat\")" "$pltfile$i.aux1" > "$pltfile$i.aux2"
	sed -e "$(echo /file3=/c\file3=\"po_OS$i.dat\")" "$pltfile$i.aux2" > "$pltfile$i.aux3"
	sed -e "$(echo /file2=/c\file2=\"po_k2S$i.dat\")" "$pltfile$i.aux3" > "$pltfile$i.aux4"
	sed -e "$(echo /lambda=/c\lambda=$lambda)" "$pltfile$i.aux4" > "$pltfile$i.plt"
	rm $pltfile$i.aux*
	#Launching gnuplot
	gnuplot $pltfile$i.plt
	rm $pltfile$i.plt
	rm po$i.dat
	rm po_OS$i.dat
	rm po_k2S$i.dat
done
