library(ggplot2)

setwd("/home/alumno25/MM/practica/5-resultados")

cat("\nVALIDACIÓN TERMODINÁMICA: 298 K vs 400 K\n")
cat("Directorio de trabajo:", getwd(), "\n\n")

dirs <- c(
  "298" = "../4-analysis-298K",
  "400" = "../4-analysis-400K"
)

archivo_g96 <- "../3-run-298K/arf.g96"
KB <- 0.008314462618

leer_n_atomos_g96 <- function(archivo) {
  if (!file.exists(archivo)) stop(paste("No se encuentra el archivo:", archivo))
  lineas <- readLines(archivo)
  inicio <- grep("^POSITION", lineas)
  fin <- grep("^END", lineas)
  fin <- fin[fin > inicio[1]][1]
  bloque <- lineas[(inicio[1] + 1):(fin - 1)]
  datos <- strsplit(trimws(bloque), "\\s+")
  as.numeric(tail(sapply(datos, `[`, 4), 1))
}

leer_xvg <- function(archivo, col = 2) {
  if (!file.exists(archivo)) {
    warning(paste("Archivo no encontrado:", archivo))
    return(list(promedio = NA, serie = data.frame()))
  }
  datos <- read.table(archivo, comment.char = "@", header = FALSE)
  if (nrow(datos) == 0 || ncol(datos) < col) {
    return(list(promedio = NA, serie = data.frame()))
  }
  serie <- data.frame(tiempo = datos[,1], valor = datos[,col])
  list(promedio = mean(serie$valor, na.rm = TRUE), serie = serie)
}

N_ATOMOS <- leer_n_atomos_g96(archivo_g96)
GRADOS_LIBERTAD <- 3 * N_ATOMOS - 6

ecin_298 <- leer_xvg(file.path(dirs["298"], "energia_cinetica.xvg"))
ecin_400 <- leer_xvg(file.path(dirs["400"], "energia_cinetica.xvg"))

temp_298 <- leer_xvg(file.path(dirs["298"], "temperatura.xvg"))
temp_400 <- leer_xvg(file.path(dirs["400"], "temperatura.xvg"))

rg_298 <- leer_xvg(file.path(dirs["298"], "gyrate.xvg"))
rg_400 <- leer_xvg(file.path(dirs["400"], "gyrate.xvg"))

etot_298 <- leer_xvg(file.path(dirs["298"], "energia_total.xvg"))
etot_400 <- leer_xvg(file.path(dirs["400"], "energia_total.xvg"))

E_teo <- c(
  "298" = 0.5 * GRADOS_LIBERTAD * KB * 298,
  "400" = 0.5 * GRADOS_LIBERTAD * KB * 400
)

error_298 <- 100 * (ecin_298$promedio - E_teo["298"]) / E_teo["298"]
error_400 <- 100 * (ecin_400$promedio - E_teo["400"]) / E_teo["400"]

tabla <- data.frame(
  Concepto = c(
    "E_cin teórica (kJ/mol)",
    "E_cin experimental (kJ/mol)",
    "Error (%)",
    "Temperatura promedio (K)",
    "Radio de giro (nm)"
  ),
  `298 K` = c(E_teo["298"], ecin_298$promedio, error_298, temp_298$promedio, rg_298$promedio),
  `400 K` = c(E_teo["400"], ecin_400$promedio, error_400, temp_400$promedio, rg_400$promedio)
)

tabla[,2:3] <- round(tabla[,2:3], 4)

cat("Número de átomos:", N_ATOMOS, "\n")
cat("Grados de libertad:", GRADOS_LIBERTAD, "\n\n")
print(tabla, row.names = FALSE)

estilo_font <- theme(
  panel.background = element_rect(fill = "white", color = "black", linewidth = 0.5),
  plot.background  = element_rect(fill = "white", color = NA),
  panel.grid.major = element_line(color = "grey85", linetype = "dotted"),
  panel.grid.minor = element_blank(),
  axis.line = element_line(color = "black"),
  axis.ticks = element_line(color = "black"),
  axis.title = element_text(face = "bold"),
  axis.text = element_text(color = "black"),
  plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
  legend.position = c(0.85, 0.9),
  legend.background = element_rect(fill = "white", color = "black", linewidth = 0.1),
  legend.title = element_blank()
)

theme_set(estilo_font)

plot_doble <- function(data1, data2, ylab, titulo, archivo, hlines = NULL) {
  p <- ggplot() +
    geom_line(data=data1, aes(tiempo, valor, color="298 K"), linewidth=0.7) +
    geom_line(data=data2, aes(tiempo, valor, color="400 K"), linewidth=0.7) +
    labs(x="Tiempo (ps)", y=ylab, title=titulo)
  
  if (!is.null(hlines)) {
    for (h in hlines) {
      p <- p + geom_hline(yintercept=h, linetype=2)
    }
  }
  
  ggsave(archivo, p, width=7, height=4.5, dpi=300)
}

if (nrow(temp_298$serie) > 0 && nrow(temp_400$serie) > 0) {
  plot_doble(temp_298$serie, temp_400$serie,
             "Temperatura (K)",
             "Evolución de la Temperatura",
             "temperatura.png",
             c(298, 400))
}

if (nrow(ecin_298$serie) > 0 && nrow(ecin_400$serie) > 0) {
  plot_doble(ecin_298$serie, ecin_400$serie,
             "Energía cinética (kJ/mol)",
             "Energía Cinética vs Equipartición",
             "energia_cinetica.png",
             c(E_teo["298"], E_teo["400"]))
}

if (nrow(rg_298$serie) > 0 && nrow(rg_400$serie) > 0) {
  plot_doble(rg_298$serie, rg_400$serie,
             "Radio de giro (nm)",
             "Evolución del Radio de Giro",
             "radio_giro.png")
}

if (nrow(etot_298$serie) > 0 && nrow(etot_400$serie) > 0) {
  plot_doble(etot_298$serie, etot_400$serie,
             "Energía total (kJ/mol)",
             "Energía Total del Sistema",
             "energia_total.png")
}

sink("reporte_validacion.txt")

cat("INFORME DE VALIDACIÓN TERMODINÁMICA\n")
cat("Fecha:", as.character(Sys.time()), "\n\n")
cat("Número de átomos:", N_ATOMOS, "\n")
cat("Grados de libertad:", GRADOS_LIBERTAD, "\n")
cat(sprintf("Constante de Boltzmann: %.6e kJ/(mol·K)\n\n", KB))

print(tabla, row.names = FALSE)

sink()