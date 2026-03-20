#!/bin/bash
#
# CONSTRUCCIÓN DEL SISTEMA
# Sistema: ACE-ALA-ARG-PHE-NME
# Genera topología, caja de simulación y solvata el sistema

set -e
echo "CONSTRUCCIÓN DEL SISTEMA"
echo ""

# Variables 
ARF_PDB="arf.pdb"
FORCE_FIELD=8        # CHARMM27
WATER_MODEL=1        # TIP3P
N_TERMINUS=2         # None (tiene ACE)
C_TERMINUS=4         # None (tiene NME)
BOX_SIZE=3.0         # nm

# Verificar que existe el archivo PDB
if [ ! -f "$ARF_PDB" ]; then
    echo "No se encuentra el archivo $ARF_PDB"
    echo "Copia el archivo arf.pdb a este directorio"
    exit 1
fi

echo "GENERACIÓN DE TOPOLOGÍA"
echo ""
echo "Campo de fuerzas: CHARMM27"
echo "Modelo de agua: TIP3P"
echo ""

gmx pdb2gmx -f $ARF_PDB -o arf.gro -p arf.top -ter <<EOF
$FORCE_FIELD
$WATER_MODEL
$N_TERMINUS
$C_TERMINUS
EOF

echo ""
echo "Topología generada, archivos: arf.gro, arf.top"
echo ""

echo "CAJA DE SIMULACIÓN"
echo ""
gmx editconf -f arf.gro -o arf-box.gro -bt cubic -box $BOX_SIZE $BOX_SIZE $BOX_SIZE

echo ""
echo "Caja cúbica: ${BOX_SIZE} × ${BOX_SIZE} × ${BOX_SIZE} nm"
echo ""

echo "ADICIÓN DE SOL AL SISTEMA"
echo ""
gmx solvate -cp arf-box.gro -cs -o arf-box-solv.gro -p arf.top

echo ""
echo "Sistema solvatado"
echo ""

echo ".PDB PARA VISUALIZAR CON PYMOL"
echo ""
gmx editconf -f arf-box-solv.gro -o arf-box-solv.pdb

echo ""
# Carpetas de build
BUILD_298="../2-equilibration-298K/build"

# Crear carpeta build si no existen
mkdir -p "$BUILD_298"

# Archivos iniciales
GRO="arf-box-solv.gro"
TOP="arf.top"
PDB="arf-box-solv.pdb"
BOX="arf-box.gro"
SOLV="arf-box-solv.gro"

echo "Archivos de entrada verificados"

# Generar PDB a partir del sistema solvatado
echo "Generando PDB..."
gmx editconf -f "$SOLV" -o "$PDB"

# Limpiar backups de GROMACS
find . -maxdepth 1 -type f -name '#*#' -exec rm -f {} \;

# Copiar archivos importantes a las carpetas build
echo "Copiando archivos a las carpetas build..."
for DIR in "$BUILD_298"; do
    cp -u "$GRO" "$DIR/"
    cp -u "$TOP" "$DIR/"
    cp -u "$PDB" "$DIR/"
    cp -u "$BOX" "$DIR/"
    cp -u "$SOLV" "$DIR/"
done

# Limpiar backups de GROMACS en builds
for DIR in "$BUILD_298"; do
    find "$DIR" -maxdepth 1 -type f -name '#*#' -exec rm -f {} \;
done

echo ""
echo "=============================================="
echo "Archivos generados y copiados a builds:"
echo "  $GRO           - Coordenadas del tripéptido"
echo "  $TOP           - Topología del sistema"
echo "  $BOX           - Sistema con caja periódica"
echo "  $SOLV          - Sistema solvatado"
echo "  $PDB           - Para visualización"

# Borrar los duplicados que GROMACS genera automáticamente (#archivo#)
for f in *; do
    if [[ "$f" == '#*#' ]]; then
        rm -f "$f"
    fi
done