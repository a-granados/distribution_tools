#/bin/bash
#This is the main distribution script.
#It takes a file and, taking into account the number of processors, it
#splits it in different blocks and launches the main computatons for
#each block: scripts compute_block.sh.

datafile=fixed_points.dat
datafiletmp=fixed_points.dat.tmp

#Commented lines will be ingored:
cat $datafile | grep "^[^#]"> $datafiletmp
num=$(cat $datafiletmp | wc -l) #Counts the number of lines

ncores=15 #Number of cores -1
deltapoints=$(echo "scale=0; $num/($ncores+1)" | bc)

for i in `seq 1 1 $ncores`;do
  let "i1=($i-1)*$deltapoints+1"
  let "i2=$i*$deltapoints"
  (./launch_block.sh $i1 $i2)&
done

let "i1=$ncores*$deltapoints+1"
(./launch_block.sh $i1 $num)&
