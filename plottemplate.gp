#GNUPLOT Version 4.6 patchlevel 6
#process with vsfg.R
#do not run directly in gnuplot
#text in all caps is replaced by R script

#first, plot 2D spectrum
reset
set terminal postscript eps enhanced color dashed linewidth 3 size 2.4,2.0
set output "FILEPLACEHOLDERplot.eps"
set pm3d map
set size square 
set key off
set tics out
set xtics rotate by -90
set border linewidth 1

set xlabel "Time (ps)"
set ylabel "Wavenumber (per cm)"
set cblabel "Transmittance" rotate by -90

#set range of color scale
#clips data

splot "FILEPLACEHOLDERreducedvsfg.gp" nonuniform matrix


#plot spectra
reset
set terminal postscript eps enhanced color dashed linewidth 3 size 3.4,2.0
set output "FILEPLACEHOLDERspectrumplot.eps"
set xlabel "Wavenumber (per cm)"
set ylabel "Transmittance"
set xtics rotate by -90
set border linewidth 1
set size square
set key outside
set key title "Time (ps)"

#get the time axis for use in the legend
header = system('head -n 1 FILEPLACEHOLDERreducedvsfg.gp')

#pick ten evenly spaced spectra
#skip the first row of the file
#put times in the legend
plot for [i=2:ROWSPLACEHOLDER:ROWSPLACEHOLDER/10] "FILEPLACEHOLDERreducedvsfg.gp" every ::1 using 1:i title  word(header, i)


#plot the wavelength-averaged data
set key off
set output "FILEPLACEHOLDERtimeplot.eps"
set xlabel "Time (ps)"
plot "FILEPLACEHOLDERreducedtime.gp"
