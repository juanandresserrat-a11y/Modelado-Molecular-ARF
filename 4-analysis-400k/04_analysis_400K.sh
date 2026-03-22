#!/bin/bash
#
# ANÁLISIS A 400 K
# Extrae propiedades y genera archivos con datos

set -e

echo "ANÁLISIS A 400 K"
echo ""

# DIRECTORIO DE PRODUCCIÓN
RUN_DIR="../3-run-400K"

# VERIFICAR ARCHIVOS NECESARIOS
if [ ! -f "$RUN_DIR/arf.tpr" ] || [ ! -f "$RUN_DIR/arf.trr" ] || [ ! -f "$RUN_DIR/arf.edr" ]; then
    echo "FALTAN ARCHIVOS DE PRODUCCIÓN"
    echo "Se esperan en $RUN_DIR:"
    echo "  arf.tpr"
    echo "  arf.trr"
    echo "  arf.edr"
    exit 1
fi

# COPIAR ARCHIVOS AL DIRECTORIO DE ANÁLISIS
cp "$RUN_DIR/arf.tpr" .
cp "$RUN_DIR/arf.trr" .
cp "$RUN_DIR/arf.edr" .


echo "EXTRACCIÓN DE ENERGÍAS"

echo "ENERGÍA TOTAL"
gmx energy -f arf.edr -s arf.tpr -xvg none -o energia_total.xvg <<EOF
15
EOF

echo "ENERGÍA CINÉTICA"
gmx energy -f arf.edr -s arf.tpr -xvg none -o energia_cinetica.xvg <<EOF
14
EOF

echo "EXTRACCIÓN DE TEMPERATURA"
gmx traj -f arf.trr -s arf.tpr -xvg none -ot temperatura.xvg <<EOF
0
EOF

echo "CÁLCULO DE RADIO DE GIRO"
gmx gyrate -f arf.trr -s arf.tpr -xvg none -o gyrate.xvg <<EOF
1
EOF

echo "CÁLCULO DE DISTANCIAS"

cat > distances.ndx <<'EOF'
[ CO-ALA-2 ]
9 10

[ CACB-ALA-2 ]
8 11
EOF

echo "DISTANCIA C=O DE ALA-2"
gmx distance -f arf.trr -s arf.tpr -n distances.ndx -oall dist_CO_ALA2.xvg -xvg none <<EOF
0
EOF

echo "DISTANCIA CA-CB DE ALA-2"
gmx distance -f arf.trr -s arf.tpr -n distances.ndx -oall dist_CACB_ALA2.xvg -xvg none <<EOF
1
EOF

echo "CÁLCULO DE ÁNGULOS"

cat > angles.ndx <<'EOF'
[ CA-C-O-ALA-2 ]
8 9 10

[ N-CA-C-ALA-2 ]
7 8 9
EOF

echo "ÁNGULO CA-C-O DE ALA-2"
gmx angle -f arf.trr -n angles.ndx -ov angulo_CA_C_O_ALA2.xvg -xvg none <<EOF
0
EOF

echo "ÁNGULO N-CA-C DE ALA-2"
gmx angle -f arf.trr -n angles.ndx -ov angulo_N_CA_C_ALA2.xvg -xvg none <<EOF
1
EOF

echo "EXTRACCIÓN DE VELOCIDADES"
gmx traj -f arf.trr -s arf.tpr -xvg none -ov velocidades.xvg <<EOF
1
EOF

N_ATOMS=$(grep "Protein" "$RUN_DIR/arf.log" 2>/dev/null | head -1 | awk '{print $3}')
[ -z "$N_ATOMS" ] && N_ATOMS=66

echo "NÚMERO DE ÁTOMOS DE PROTEÍNA: $N_ATOMS"

awk 'NR==1 || NR % '$N_ATOMS' == 1' velocidades.xvg > vel_atomo1.xvg
awk 'NR==2 || NR % '$N_ATOMS' == 2' velocidades.xvg > vel_atomo2.xvg
awk 'NR==3 || NR % '$N_ATOMS' == 3' velocidades.xvg > vel_atomo3.xvg
awk 'NR==4 || NR % '$N_ATOMS' == 4' velocidades.xvg > vel_atomo4.xvg
awk 'NR==5 || NR % '$N_ATOMS' == 5' velocidades.xvg > vel_atomo5.xvg

# BORRAR DUPLICADOS GENERADOS POR GROMACS
for f in *; do
    if [[ "$f" == \#*# ]]; then
        rm -f "$f"
    fi
done

echo ""
echo "=============================================="
echo "TOTAL DE ARCHIVOS GENERADOS: $(ls *.xvg 2>/dev/null | wc -l)"
