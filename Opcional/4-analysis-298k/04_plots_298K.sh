#!/bin/bash
set -e

# Cargar PATH completo
export PATH=/usr/bin:/bin:/usr/local/bin:$PATH

echo "GRÁFICAS A 298 K"

GNUPLOT=/usr/bin/gnuplot

REQUIRED_FILES=(energia_total.xvg energia_cinetica.xvg temperatura.xvg gyrate.xvg dist_CO_ALA2.xvg dist_CACB_ALA2.xvg angulo_CA_C_O_ALA2.xvg angulo_N_CA_C_ALA2.xvg ramachandran-ala2.dat ramachandran-arg3.dat ramachandran-phe4.dat vel_atomo1.xvg)

for f in "${REQUIRED_FILES[@]}"; do
    [ ! -f "$f" ] && echo "FALTA $f" && exit 1
done

echo "GENERANDO GRÁFICAS"

$GNUPLOT <<'EOF'
set terminal png size 1200,800
set output 'energia_total_298K.png'
set xlabel 'Tiempo (ps)'
set ylabel 'Energia Total (kJ/mol)'
set title 'Energia Total - 298K'
set grid
plot 'energia_total.xvg' with linespoints lw 2 title 'E_total'
EOF

$GNUPLOT <<'EOF'
set terminal png size 1200,800
set output 'energia_cinetica_298K.png'
set xlabel 'Tiempo (ps)'
set ylabel 'Energia Cinetica (kJ/mol)'
set title 'Energia Cinetica - 298K'
set grid
plot 'energia_cinetica.xvg' with linespoints lw 2 title 'E_cin'
EOF

$GNUPLOT <<'EOF'
set terminal png size 1200,800
set output 'temperatura_298K.png'
set xlabel 'Tiempo (ps)'
set ylabel 'Temperatura (K)'
set title 'Temperatura - 298K'
set grid
plot 'temperatura.xvg' with linespoints lw 2 title 'T'
EOF

$GNUPLOT <<'EOF'
set terminal png size 1200,800
set output 'gyrate_298K.png'
set xlabel 'Tiempo (ps)'
set ylabel 'Radio de Giro (nm)'
set title 'Radio de Giro - 298K'
set grid
plot 'gyrate.xvg' using 1:2 with linespoints lw 2 title 'Rgyr'
EOF

$GNUPLOT <<'EOF'
set terminal png size 1200,800
set output 'distancias_298K.png'
set xlabel 'Tiempo (ps)'
set ylabel 'Distancia (nm)'
set title 'Distancias de Enlace - 298K'
set grid
plot 'dist_CO_ALA2.xvg' with linespoints lw 2 title 'C=O ALA-2', \
     'dist_CACB_ALA2.xvg' with linespoints lw 2 title 'CA-CB ALA-2'
EOF

$GNUPLOT <<'EOF'
set terminal png size 1200,800
set output 'angulos_298K.png'
set xlabel 'Tiempo (ps)'
set ylabel 'Angulo (grados)'
set title 'Angulos - 298K'
set grid
plot 'angulo_CA_C_O_ALA2.xvg' with linespoints lw 2 title 'CA-C-O', \
     'angulo_N_CA_C_ALA2.xvg' with linespoints lw 2 title 'N-CA-C'
EOF

$GNUPLOT <<'EOF'
set terminal png size 1000,1000
set output 'ramachandran_ALA2_298K.png'
set xlabel 'Phi (grados)'
set ylabel 'Psi (grados)'
set title 'Ramachandran ALA-2 - 298K'
set xrange [-180:180]
set yrange [-180:180]
set size square
set grid
plot 'ramachandran-ala2.dat' using 2:3 with points pt 7 ps 0.5 notitle
EOF

$GNUPLOT <<'EOF'
set terminal png size 1000,1000
set output 'ramachandran_ARG3_298K.png'
set xlabel 'Phi (grados)'
set ylabel 'Psi (grados)'
set title 'Ramachandran ARG-3 - 298K'
set xrange [-180:180]
set yrange [-180:180]
set size square
set grid
plot 'ramachandran-arg3.dat' using 2:3 with points pt 7 ps 0.5 notitle
EOF

$GNUPLOT <<'EOF'
set terminal png size 1000,1000
set output 'ramachandran_PHE4_298K.png'
set xlabel 'Phi (grados)'
set ylabel 'Psi (grados)'
set title 'Ramachandran PHE-4 - 298K'
set xrange [-180:180]
set yrange [-180:180]
set size square
set grid
plot 'ramachandran-phe4.dat' using 2:3 with points pt 7 ps 0.5 notitle
EOF

$GNUPLOT <<'EOF'
set terminal png size 1200,800
set output 'velocidades_298K.png'
set xlabel 'Tiempo (ps)'
set ylabel 'Velocidad (nm/ps)'
set title 'Velocidades - 298K'
set grid
plot 'vel_atomo1.xvg' using 1:5 with lines title 'At1', \
     'vel_atomo2.xvg' using 1:5 with lines title 'At2', \
     'vel_atomo3.xvg' using 1:5 with lines title 'At3', \
     'vel_atomo4.xvg' using 1:5 with lines title 'At4', \
     'vel_atomo5.xvg' using 1:5 with lines title 'At5'
EOF

$GNUPLOT <<'EOF'
set terminal png size 1200,800
set output 'histograma_temperatura_298K.png'
set xlabel 'Temperatura (K)'
set ylabel 'Frecuencia'
set title 'Distribucion Temperatura - 298K'
set style fill solid 0.5
width = 2
hist(x,width) = width*floor(x/width)+width/2.0
set boxwidth width*0.9
plot 'temperatura.xvg' using (hist($2,width)):(1.0) smooth freq with boxes notitle
EOF


echo ""
echo "GRÁFICAS GENERADAS"
echo ""
echo "ARCHIVOS PNG CREADOS:"
ls -1 *.png
echo ""
echo "TOTAL DE GRÁFICAS: $(ls *.png | wc -l)"
echo ""




