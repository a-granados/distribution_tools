#This is a gnuplot script to general frames for a video from the date
#created by distribute_averages_*.sh
unset key
set terminal jpeg size 1280,480

set output "tmp~/regions-orbits.jpg"
set macros
boxtype = "nohead front ls 2 lw 2"

set multiplot

file="output.tna"
A=0.642
maxperiod=18

set ylabel "theta"
set xlabel "V"
title=sprintf("amplitude=%.3f",A)
set title title

set origin 0.5,0
set size 0.5,1
set yrange [1.04:1.15]
set xrange [0:1]
plot file u ($1==-1 ? $2 : 1/0):3,\
file u ($1==0 ? $2 : 1/0):3, file u ($1==1 ? $2 : 1/0):3,\
file u ($1==2 ? $2 : 1/0):3, file u ($1==3 ? $2 : 1/0):3,\
file u ($1==-2 ? $2 : 1/0):3 w p pt 7 ps 2

set ytics
set xtics
set ylabel "p"
set xlabel "1/A"
set title "Periods"
set origin 0,0
set size 0.5,1
set xrange[0.2:0.6]
set yrange[0:maxperiod+2]
set arrow from A,0 to A,maxperiod nohead
plot "period.tna" w p pt 3 ps 0.5
