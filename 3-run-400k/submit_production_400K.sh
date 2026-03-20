#!/bin/bash
#SBATCH -p eck-q
#SBATCH --chdir=/home/alumno25/MM/practica/3-run-400K
#SBATCH -J prod-400K
#SBATCH --cpus-per-task=1
#SBATCH --output=production_400K_%j.out
#SBATCH --error=production_400K_%j.err

echo "PRODUCCIÓN ARF - 400 K"
echo "Inicio: $(date)"
echo "Nodo: $(hostname)"
echo "Directorio: $(pwd)"
echo ""

date
gmx mdrun -deffnm arf -c arf.g96 -nt 1
date

echo "Archivos generados:"
ls -lh arf.trr arf.edr arf.log arf.g96
