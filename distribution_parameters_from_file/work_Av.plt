unset key
set terminal jpeg size 1280,480

set output "po1.jpg"
set multiplot
file="trajectory1.dat"
file2="trajectory2.dat"
file3="trajectory3.dat"

#set xrange [-10:25]
#set yrange [-15:50]

lambda=0.01
title=sprintf("Lambda=%.7f",lambda)
set title title

set origin 0.5,0
set size 0.5,0.5

plot file w l,\
file2 every ::2500::3000

set origin 0.5,0.5
set size 0.5,0.5

plot file3 every ::2500::3000,\
-x**2/2-x**3/3

set origin 0,0
set size 0.5,1

#set xrange [0:0.2]
set yrange [*:*]
set xrange [*:*]

set arrow from lambda,0 to lambda,50

plot "fixed_points_eps0d01.dat" u 1:($4/(2*pi))
