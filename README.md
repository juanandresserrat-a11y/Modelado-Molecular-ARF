# Modelado Molecular — Tripéptido ARF

Simulación de dinámica molecular del tripéptido ACE-ALA-ARG-PHE-NME en solución acuosa.
Ensemble NVT a 298 K y 400 K, campo de fuerzas CHARMM27, agua TIP3P flexible, GROMACS 2016.4.

Autor: Juan Andrés Serrat Hurtado — Máster en Bioinformática 2025-2026

---

## Requisitos

- GROMACS 2016.4
- R >= 4.0 con paquetes: ggplot2, dplyr, tidyr
- SLURM (sbatch)

---

## Ejecución

Los scripts deben ejecutarse en orden. Cada paso depende del anterior.

### Paso 1 — Construcción del sistema

    bash 01_construccion.sh

Genera la caja, solvata el péptido (~860 moléculas de agua, ~2629 átomos totales) y copia los archivos a los directorios de equilibración.

### Paso 2 — Neutralización y equilibrado (400 ps)

    bash 02_equilibration_298K.sh      # o sbatch submit_equilibration_298K.sh
    bash 02_equilibration_400K.sh      # o sbatch submit_equilibration_400K.sh

Neutraliza la carga neta +1 del péptido añadiendo un ion Cl- y equilibra el sistema a cada temperatura.

### Paso 3 — Producción básica (2 ps)

    bash 03_production_298K.sh         # o sbatch submit_production_298K.sh
    bash 03_production_400K.sh         # o sbatch submit_production_400K.sh

Continúa la dinámica desde el estado final del equilibrado. No genera velocidades nuevas.

### Paso 4 — Análisis y gráficos

    bash 04_analysis_298K.sh
    bash 04_plots_298K.sh
    bash 04_analysis_400K.sh
    bash 04_plots_400K.sh

Extrae energía, temperatura, distancias, ángulos, radio de giro y velocidades. Genera los gráficos individuales por temperatura.

### Paso 5 — Validación comparativa

    Rscript 05_validation.R

Gráficos comparativos entre 298 K y 400 K con mayor calidad visual usando ggplot2.

---

## Opcional — Simulación extendida (500 ps, 298 K)

    bash Opcional/01_construccion_298K.sh
    bash Opcional/02_equilibration_298K.sh
    bash Opcional/03_production_500ps.sh
    bash Opcional/04_analysis_500ps.sh
    bash Opcional/04_plots_298K.sh       # vestigio del flujo básico, útil para comprobación interna
    Rscript Opcional/05_validation_500ps.R

Genera histogramas de temperatura, distribuciones de velocidad y diagramas de Ramachandran para los tres residuos (Ala-2, Arg-3, Phe-4).

---

## Notas

- dt = 0.5 fs obligatorio con TIP3P flexible. No aumentar sin cambiar el modelo de agua.
- Para adaptar a otro péptido: reemplazar arf.pdb y actualizar referencias en 01_construccion.sh.
- Los scripts SLURM usan 1 CPU por defecto. Modificar según el clúster.
