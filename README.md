# Modelado-Molecular-ARF
Simulación de Dinámica Molecular del Tripéptido ARF
(7920) Modelado Molecular — Máster Universitario en Bioinformática [25/26]

Autor: Juan Andrés Serrat Hurtado
Fecha: 2026-03-20
Sistema: ACE-ALA-ARG-PHE-NME (ARF) en solución acuosa
Software: GROMACS 2016.4
Campo de fuerzas: CHARMM27
Modelo de agua: TIP3P (flexible)

Descripción general
Este repositorio contiene los scripts necesarios para reproducir simulaciones de dinámica molecular del tripéptido ARF en agua. Las simulaciones se realizan en el ensemble NVT a dos temperaturas, 298 K y 400 K, con paso de tiempo de 0,5 fs y termostato velocity-rescale. El flujo de trabajo está organizado en pasos secuenciales que incluyen construcción del sistema, equilibrado, producción básica, análisis individual y validación comparativa. Además, se incluye una simulación extendida de 500 ps a 298 K para un muestreo más completo.

Estructura del repositorio
.
├── arf.pdb                       Coordenadas iniciales del tripéptido
├── 01_construccion.sh             Construcción del sistema unificada
├── Opcional/                      Scripts de construcción por temperatura
│   ├── 01_construccion_298K.sh
│   └── 01_construccion_400K.sh
├── 02_equilibration_298K.sh       Equilibrado a 298 K
├── 02_equilibration_400K.sh       Equilibrado a 400 K
├── 03_production_298K.sh          Producción básica 2 ps a 298 K
├── 03_production_400K.sh          Producción básica 2 ps a 400 K
├── 04_analysis_298K.sh            Extracción de propiedades a 298 K
├── 04_analysis_400K.sh            Extracción de propiedades a 400 K
├── 04_plots_298K.sh               Generación de gráficos a 298 K
├── 04_plots_400K.sh               Generación de gráficos a 400 K
├── 05_validation.R                Comparación entre temperaturas
├── mdp/                           Archivos de parámetros de simulación
│   ├── equiNVT_298K.mdp
│   ├── equiNVT_400K.mdp
│   ├── runNVT_298K.mdp
│   ├── runNVT_400K.mdp
│   └── runNVT_500ps.mdp
└── extended/                       Simulación extendida 500 ps
    ├── 03_production_500ps.sh
    ├── 04_analysis_500ps.sh
    ├── 04_plots_500ps.sh
    └── 05_validation_500ps.R

Requisitos
GROMACS 2016.4
R ≥ 4.0
Paquetes R: ggplot2, dplyr, tidyr
Gestor de colas: SLURM (sbatch)

Asegúrate de que GROMACS está en tu PATH ejecutando:
gmx --version

Uso general
Todos los scripts deben ejecutarse en orden, ya que cada paso depende de los archivos generados por el anterior.
En la carpeta Opcional/ hay scripts separados para la parte avanzada.

Paso 1: Construcción del sistema
Ejecuta el script unificado para generar la caja, solvatar el péptido y preparar directorios.
bash 01_construccion.sh
Archivos de salida: arf.gro, arf.top, posre.itp, arf-box.gro, arf-box-solv.gro, arf-box-solv.pdb

Paso 2: Neutralización y equilibrado
Neutraliza la carga neta del péptido y ejecuta el equilibrado a 298 K y 400 K:
bash 02_equilibration_298K.sh
bash 02_equilibration_400K.sh
Duración: 400 ps, salida cada 0,1 ps

Paso 3: Producción básica
Simulación de 2 ps a cada temperatura:
bash 03_production_298K.sh
bash 03_production_400K.sh

Paso 4: Análisis individual
Extrae propiedades termodinámicas y estructurales, y genera archivos para gráficas:
bash 04_analysis_298K.sh
bash 04_plots_298K.sh
bash 04_analysis_400K.sh
bash 04_plots_400K.sh
Propiedades: energía, temperatura, distancias y ángulos de enlace, radio de giro, velocidades y ángulos de Ramachandran

Paso 5: Validación comparativa
Genera gráficos comparativos entre 298 K y 400 K:
Rscript 05_validation.R

Simulación extendida (500 ps)
Para obtener muestreo conformacional más completo a 298 K:
bash opcional/01_construccion_298K.sh
bash opcional/02_equilibration_298K.sh
bash opcional/03_production_500ps.sh
bash opcional/04_analysis_500ps.sh
bash opcional/04_plots_500ps.sh
Rscript opcional/05_validation_500ps.R
Se generan histogramas de temperatura, distribuciones de velocidad y mapas de Ramachandran para todos los residuos

Notas
Adaptación a otro péptido: reemplaza arf.pdb y actualiza referencias en 01_construccion.sh
Gestión de colas: los scripts SLURM solicitan 1 CPU por defecto; modifica según tu clúster
Paso de tiempo: TIP3P flexible requiere 0,5 fs para vibraciones O-H. No aumentes dt sin ajustar el modelo de agua
Neutralización: el aviso de carga neta antes de equilibrado es normal; los scripts lo corrigen automáticamente
