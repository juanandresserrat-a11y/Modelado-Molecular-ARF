#!/bin/bash
#
# EQUILIBRACIÓN A 298 K
# Neutraliza el sistema y ejecuta equilibración de 400 ps
# Considera que los archivos iniciales (excepto el .mdp) están en build

set -e

echo "EQUILIBRACIÓN A 298 K"
echo ""

# Variables
EQUI_MDP="equiNVT_298k.mdp"

# Modificar esta variable en caso de tripeptido con distinta carga
N_IONS=1   

BUILD_DIR="./build"  

# Verificar archivos necesarios
if [ ! -f "$BUILD_DIR/arf-box-solv.gro" ] || [ ! -f "$BUILD_DIR/arf.top" ]; then
    echo "Faltan archivos en build"
    echo "Coloca arf-box-solv.gro y arf.top en $BUILD_DIR"
    exit 1
fi

if [ ! -f "$EQUI_MDP" ]; then
    echo "No se encuentra $EQUI_MDP"
    exit 1
fi

# Copiar los archivos necesarios desde build al directorio actual
cp "$BUILD_DIR/arf-box-solv.gro" .
cp "$BUILD_DIR/arf.top" .

echo "Parámetros por defecto en $EQUI_MDP serán usados"
echo "Temperatura y tiempo definidos en el archivo .mdp"

echo "GENERACIÓN TPR INICIAL"
gmx grompp -f $EQUI_MDP -c arf-box-solv.gro -p arf.top -o arf-a.tpr -maxwarn 1

echo ""
echo "NEUTRALIZADO DEL SISTEMA"
echo "Añadiendo $N_IONS iones Cl⁻ para neutralizar carga"
gmx genion -s arf-a.tpr -p arf.top -o arf.gro -nn $N_IONS <<EOF
SOL
EOF

echo "TPR FINAL"
gmx grompp -f $EQUI_MDP -c arf.gro -p arf.top -o arf.tpr

echo ""
echo "Archivo TPR generado: arf.tpr"
echo ""

# Script SLURM
cat > submit_equilibration_298K.sh <<'EOFSCRIPT'
#!/bin/bash
#SBATCH -p eck-q
#SBATCH --chdir=/home/alumno25/MM/practica/2-equilibration-298K
#SBATCH -J equil-298K
#SBATCH --cpus-per-task=1
#SBATCH --output=equilibration_298K_%j.out
#SBATCH --error=equilibration_298K_%j.err

echo "EQUILIBRACIÓN ARF - 298 K"
echo "Inicio: $(date)"
echo "Nodo: $(hostname)"
echo "Directorio: $(pwd)"
echo ""

date
gmx mdrun -deffnm arf -c arf.g96 -nt 1
date
echo "Archivos generados:"
ls -lh arf.g96 arf.log arf.edr arf.trr
EOFSCRIPT

chmod +x submit_equilibration_298K.sh

echo ""
echo "=============================================="
echo "Archivos generados:"
echo "  arf.gro                        - Sistema neutralizado"
echo "  arf.top                        - Topología actualizada"
echo "  arf.tpr                        - Archivo binario de entrada"
echo "  submit_equilibration_298K.sh   - Script para SLURM"

# Borrar los duplicados que GROMACS genera automáticamente (#archivo#)
for f in *; do
    if [[ "$f" == \#*# ]]; then
        rm -f "$f"
    fi
done


