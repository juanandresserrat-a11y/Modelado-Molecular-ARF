#!/bin/bash
#
# PRODUCCIÓN A 298 K
# Ejecuta simulación de producción de 2 ps
# Lee archivos desde 2-equilibration-298K

set -e

echo "PRODUCCIÓN A 298 K"
echo ""

# Variables
RUN_MDP="runNVT_298K.mdp"
EQUI_DIR="../2-equilibration-298K"

# Verificar archivos necesarios
if [ ! -f "$EQUI_DIR/arf.g96" ] || [ ! -f "$EQUI_DIR/arf.top" ]; then
    echo "Faltan archivos de equilibración en $EQUI_DIR"
    echo "Se requieren: arf.g96 y arf.top"
    exit 1
fi

if [ ! -f "$RUN_MDP" ]; then
    echo "No se encuentra $RUN_MDP en el directorio actual"
    exit 1
fi

# Copiar archivos necesarios desde equilibración
cp "$EQUI_DIR/arf.g96" .
cp "$EQUI_DIR/arf.top" .

echo "Parámetros definidos en $RUN_MDP"
echo "Temperatura: 298 K"
echo "Tiempo: 2 ps"
echo ""

echo "GENERACIÓN TPR DE PRODUCCIÓN"
gmx grompp -f $RUN_MDP -c arf.g96 -p arf.top -o arf.tpr

echo ""
echo "Archivo TPR generado: arf.tpr"
echo ""

# Script SLURM
cat > submit_production_298K.sh <<'EOFSCRIPT'
#!/bin/bash
#SBATCH -p eck-q
#SBATCH --chdir=/home/alumno25/MM/practica/3-run-298K
#SBATCH -J prod-298K
#SBATCH --cpus-per-task=1
#SBATCH --output=production_298K_%j.out
#SBATCH --error=production_298K_%j.err

echo "PRODUCCIÓN ARF - 298 K"
echo "Inicio: $(date)"
echo "Nodo: $(hostname)"
echo "Directorio: $(pwd)"
echo ""

date
gmx mdrun -deffnm arf -c arf.g96 -nt 1
date

echo "Archivos generados:"
ls -lh arf.trr arf.edr arf.log arf.g96
echo ""
echo "Tamaño de trayectoria:"
du -h arf.trr
EOFSCRIPT

chmod +x submit_production_298K.sh

# Limpieza de duplicados de GROMACS (#archivo#)
for f in *; do
    if [[ "$f" == \#*# ]]; then
        rm -f "$f"
    fi
done

echo ""
echo "=============================================="
echo "Archivos listos para producción:"
echo "  arf.tpr"
echo "  submit_production_298K.sh"



