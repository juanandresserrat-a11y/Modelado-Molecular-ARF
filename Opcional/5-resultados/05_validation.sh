#!/bin/bash
set -e

echo "VALIDACIÓN TERMODINÁMICA 298 K vs 400 K"
echo "========================================"

# Directorios de análisis
DIR_298K="../4-analysis-298K"
DIR_400K="../4-analysis-400K"

# Constantes
KB=0.0083144626  # kJ/(mol·K)

# Obtener número de átomos del sistema
N_ATOMOS=$(head -2 ../3-run-298K/arf.g96 2>/dev/null | tail -1 | awk '{print $1}')
if [ -z "$N_ATOMOS" ]; then
    echo "ADVERTENCIA: No se pudo leer N_ATOMOS del archivo, usando valor estimado"
    N_ATOMOS=2629
fi

echo "Número de átomos del sistema: $N_ATOMOS"
echo ""

# FUNCIÓN PARA LEER PROMEDIOS DE ARCHIVOS .XVG
promedio_xvg() {
    archivo="$1"
    columna="${2:-2}"
    
    if [ ! -f "$archivo" ]; then
        echo "0.0000"
        return 1
    fi
    
    awk -v col="$columna" '
    /^[[:space:]]*[0-9]/ || /^[[:space:]]*[-]?[0-9]/ {
        if (NF >= col) {
            sum += $col
            count++
        }
    }
    END {
        if (count > 0) printf "%.4f", sum/count
        else print "0.0000"
    }' "$archivo"
}

# CÁLCULOS DE ENERGÍA CINÉTICA
echo "Calculando energías cinéticas..."

# Valores teóricos (equipartición)
EKIN_TEO_298=$(echo "scale=4; $N_ATOMOS * 1.5 * $KB * 298" | bc)
EKIN_TEO_400=$(echo "scale=4; $N_ATOMOS * 1.5 * $KB * 400" | bc)

# Valores experimentales (promedios)
EKIN_EXP_298=$(promedio_xvg "$DIR_298K/energia_cinetica.xvg" 2)
EKIN_EXP_400=$(promedio_xvg "$DIR_400K/energia_cinetica.xvg" 2)

# Errores porcentuales
ERROR_298=$(echo "scale=2; ($EKIN_EXP_298 - $EKIN_TEO_298)/$EKIN_TEO_298*100" | bc 2>/dev/null || echo "0.00")
ERROR_400=$(echo "scale=2; ($EKIN_EXP_400 - $EKIN_TEO_400)/$EKIN_TEO_400*100" | bc 2>/dev/null || echo "0.00")

echo "✓ Energías calculadas"
echo ""

# GENERAR GRÁFICAS DE COMPARACIÓN
echo "Generando gráficas comparativas..."

if command -v gnuplot &>/dev/null; then

    # Temperatura
    gnuplot <<EOF
set terminal pngcairo size 1200,800 enhanced font 'Arial,12'
set output 'temperatura_comparacion.png'
set xlabel 'Tiempo (ps)'
set ylabel 'Temperatura (K)'
set title 'Evolución Temporal de la Temperatura'
set grid
set key top right
plot '$DIR_298K/temperatura.xvg' using 1:2 with lines lw 2 lc rgb'blue' title '298 K', \
     '$DIR_400K/temperatura.xvg' using 1:2 with lines lw 2 lc rgb'red' title '400 K', \
     298 lc rgb'blue' dt 2 lw 1 notitle, \
     400 lc rgb'red' dt 2 lw 1 notitle
EOF

    # Energía total
    gnuplot <<EOF
set terminal pngcairo size 1200,800 enhanced font 'Arial,12'
set output 'energia_total_comparacion.png'
set xlabel 'Tiempo (ps)'
set ylabel 'Energía Total (kJ/mol)'
set title 'Evolución Temporal de la Energía Total'
set grid
set key top right
plot '$DIR_298K/energia_total.xvg' using 1:2 with lines lw 2 lc rgb'blue' title '298 K', \
     '$DIR_400K/energia_total.xvg' using 1:2 with lines lw 2 lc rgb'red' title '400 K'
EOF

    # Energía cinética con líneas teóricas
    gnuplot <<EOF
set terminal pngcairo size 1200,800 enhanced font 'Arial,12'
set output 'energia_cinetica_comparacion.png'
set xlabel 'Tiempo (ps)'
set ylabel 'Energía Cinética (kJ/mol)'
set title 'Energía Cinética: Experimental vs Teórica'
set grid
set key top right
plot '$DIR_298K/energia_cinetica.xvg' using 1:2 with lines lw 2 lc rgb'blue' title '298 K (Exp)', \
     '$DIR_400K/energia_cinetica.xvg' using 1:2 with lines lw 2 lc rgb'red' title '400 K (Exp)', \
     $EKIN_TEO_298 lc rgb'blue' dt 2 lw 2 title '298 K (Teórica)', \
     $EKIN_TEO_400 lc rgb'red' dt 2 lw 2 title '400 K (Teórica)'
EOF

    # Radio de giro
    gnuplot <<EOF
set terminal pngcairo size 1200,800 enhanced font 'Arial,12'
set output 'radio_giro_comparacion.png'
set xlabel 'Tiempo (ps)'
set ylabel 'Radio de Giro (nm)'
set title 'Evolución Temporal del Radio de Giro'
set grid
set key top right
plot '$DIR_298K/gyrate.xvg' using 1:2 with lines lw 2 lc rgb'blue' title '298 K', \
     '$DIR_400K/gyrate.xvg' using 1:2 with lines lw 2 lc rgb'red' title '400 K'
EOF

    # Distancias
    gnuplot <<EOF
set terminal pngcairo size 1200,800 enhanced font 'Arial,12'
set output 'distancias_comparacion.png'
set xlabel 'Tiempo (ps)'
set ylabel 'Distancia (nm)'
set title 'Distancias de Enlace: 298 K vs 400 K'
set grid
set key top right
plot '$DIR_298K/dist_CO_ALA2.xvg' using 1:2 with lines lw 2 lc rgb'blue' title 'C=O 298K', \
     '$DIR_400K/dist_CO_ALA2.xvg' using 1:2 with lines lw 2 lc rgb'red' title 'C=O 400K', \
     '$DIR_298K/dist_CACB_ALA2.xvg' using 1:2 with lines lw 2 dt 2 lc rgb'blue' title 'CA-CB 298K', \
     '$DIR_400K/dist_CACB_ALA2.xvg' using 1:2 with lines lw 2 dt 2 lc rgb'red' title 'CA-CB 400K'
EOF

    # Ángulos
    gnuplot <<EOF
set terminal pngcairo size 1200,800 enhanced font 'Arial,12'
set output 'angulos_comparacion.png'
set xlabel 'Tiempo (ps)'
set ylabel 'Ángulo (grados)'
set title 'Ángulos: 298 K vs 400 K'
set grid
set key top right
plot '$DIR_298K/angulo_CA_C_O_ALA2.xvg' using 1:2 with lines lw 2 lc rgb'blue' title 'CA-C-O 298K', \
     '$DIR_400K/angulo_CA_C_O_ALA2.xvg' using 1:2 with lines lw 2 lc rgb'red' title 'CA-C-O 400K', \
     '$DIR_298K/angulo_N_CA_C_ALA2.xvg' using 1:2 with lines lw 2 dt 2 lc rgb'blue' title 'N-CA-C 298K', \
     '$DIR_400K/angulo_N_CA_C_ALA2.xvg' using 1:2 with lines lw 2 dt 2 lc rgb'red' title 'N-CA-C 400K'
EOF

    # Velocidades
    gnuplot <<EOF
set terminal pngcairo size 1200,800 enhanced font 'Arial,12'
set output 'velocidades_comparacion.png'
set xlabel 'Tiempo (ps)'
set ylabel 'Velocidad (nm/ps)'
set title 'Velocidades Átomo 1: 298 K vs 400 K'
set grid
set key top right
plot '$DIR_298K/vel_atomo1.xvg' using 1:5 with lines lw 1.5 lc rgb'blue' title '298 K', \
     '$DIR_400K/vel_atomo1.xvg' using 1:5 with lines lw 1.5 lc rgb'red' title '400 K'
EOF

    echo "✓ Gráficas generadas"

else
    echo "ADVERTENCIA: gnuplot no disponible, gráficas no generadas"
fi

echo ""

# GENERAR REPORTE RESUMIDO
cat > reporte_validacion.txt <<EOF
INFORME DE VALIDACIÓN TERMODINÁMICA
====================================
Sistema: ACE-ALA-ARG-PHE-NME
Fecha: $(date)

PARÁMETROS:
- Número de átomos: $N_ATOMOS
- Constante de Boltzmann: $KB kJ/(mol·K)
- Fórmula teórica: E_cin = (3/2) × N × k_B × T

RESULTADOS COMPARATIVOS:
─────────────────────────────────────────────
                       298 K         400 K
─────────────────────────────────────────────
Temperatura objetivo   298 K         400 K
E_cin teórica         $EKIN_TEO_298  $EKIN_TEO_400 kJ/mol
E_cin experimental    $EKIN_EXP_298  $EKIN_EXP_400 kJ/mol
Error porcentual      $ERROR_298%    $ERROR_400%
─────────────────────────────────────────────

INTERPRETACIÓN:
- La energía cinética experimental debe aproximarse a la teórica
  según el teorema de equipartición de la energía.
- Un error < 5% indica excelente equilibrio térmico.
- Un error < 10% indica buen equilibrio térmico.
- Temperaturas más altas producen mayores energías cinéticas.

GRÁFICAS GENERADAS:
- temperatura_comparacion.png
- energia_total_comparacion.png  
- energia_cinetica_comparacion.png
- radio_giro_comparacion.png
- distancias_comparacion.png
- angulos_comparacion.png
- velocidades_comparacion.png

Los diagramas de Ramachandran (dihedros) están disponibles en:
- ../4-analysis-298K/ramachandran_*.png
- ../4-analysis-400K/ramachandran_*.png
EOF

# Limpiar archivos temporales
rm -f \#*#

# MOSTRAR RESUMEN FINAL
echo "VALIDACIÓN COMPLETADA"
echo "====================="
echo ""
echo "Energía cinética teórica vs experimental:"
echo "• 298 K: $EKIN_TEO_298 kJ/mol (teórica) vs $EKIN_EXP_298 kJ/mol (exp)"
echo "• 400 K: $EKIN_TEO_400 kJ/mol (teórica) vs $EKIN_EXP_400 kJ/mol (exp)"
echo ""
echo "Errores porcentuales:"
echo "• 298 K: $ERROR_298%"
echo "• 400 K: $ERROR_400%"
echo ""
echo "Archivos generados:"
echo "• reporte_validacion.txt (resumen para el PDF)"
if command -v gnuplot &>/dev/null; then
    echo "• 7 gráficas PNG de comparación"
fi
echo ""
echo "Total archivos: $(ls *.png 2>/dev/null | wc -l) gráficas + 1 reporte"
echo ""