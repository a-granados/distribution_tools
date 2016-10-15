#!/bin/bash

prefix=regions-orbits
n=$(ls *jpg | wc -l)
for i in `seq 1 1 $n` ;do
	cp $prefix"$i".jpg $(printf "frame_%0.3d.jpg" $i)
done
