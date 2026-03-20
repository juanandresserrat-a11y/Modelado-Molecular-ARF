#!/bin/bash
#SBATCH -p eck-q
#SBATCH --chdir=/home/alumno25/MM/practica/2-equilibration-400K
#SBATCH -J equil-400K
#SBATCH --cpus-per-task=1
#SBATCH --output=equilibration_400K_%j.out
#SBATCH --error=equilibration_400K_%j.err

echo "EQUILIBRACIÓN ARF - 400 K"
echo "Inicio: $(date)"
echo "Nodo: $(hostname)"
echo "Directorio: $(pwd)"
echo ""

date
gmx mdrun -deffnm arf -c arf.g96 -nt 1
date

echo "Archivos generados:"
ls -lh arf.g96 arf.log arf.edr arf.trr
