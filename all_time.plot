reset;
set xdata time;
set yrange [0:];
set timefmt "%s";
set format x "%d/%m %H:%M";

unset key;

set terminal svg;
set output "temperature.svg"
set title "Temperature at Pruby's desk";
set xtics 3600 rotate;
set ylabel "Temperature (K)"
plot 'section.log' using 1:2 smooth csplines;

reset;
set xdata time;
set yrange [0:100];
set timefmt "%s";
set format x "%d/%m %H:%M";

unset key;

set terminal svg;
set output "humidity.svg";
set title "Humidity at Pruby's desk";
set xtics 3600 rotate;
set ylabel "Relative Humidity (%)"
plot 'section.log' using 1:3 smooth csplines;

