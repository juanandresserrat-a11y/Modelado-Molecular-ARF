library(ggplot2)
library(viridis)

setwd("/home/alumno25/MM/practica/Opcional/5-resultados")

dir_298 <- "../4-analysis-298K"

archivo_temp <- file.path(dir_298, "temperatura.xvg")
archivo_vel  <- file.path(dir_298, "vel_atomo1.xvg")

rama_files <- list(
  ALA2 = file.path(dir_298, "ramachandran-ala2.dat"),
  ARG3 = file.path(dir_298, "ramachandran-arg3.dat"),
  PHE4 = file.path(dir_298, "ramachandran-phe4.dat")
)

leer_xvg <- function(archivo) {
  read.table(archivo, comment.char = "@", header = FALSE)
}

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
  legend.background = element_rect(fill = "white", color = "black", linewidth = 0.2),
  legend.title = element_blank()
)

theme_set(estilo_font)

temp <- leer_xvg(archivo_temp)
colnames(temp) <- c("tiempo", "temperatura")

bins_temp <- nclass.FD(temp$temperatura)

ggsave("hist_temperatura_298K.png",
       ggplot(temp, aes(x = temperatura)) +
         geom_histogram(bins = bins_temp, fill = "#3A7CA5", color = "black", show.legend = FALSE) +
         labs(title = "Distribución de la Temperatura (298 K)",
              x = "Temperatura (K)", y = "Frecuencia"),
       width = 6, height = 4, dpi = 300)

vel <- leer_xvg(archivo_vel)
colnames(vel) <- c("tiempo", "vx", "vy", "vz")

bins_vx <- nclass.FD(vel$vx)
bins_vy <- nclass.FD(vel$vy)
bins_vz <- nclass.FD(vel$vz)

ggsave("hist_vx_298K.png",
       ggplot(vel, aes(x = vx)) +
         geom_histogram(bins = bins_vx, fill = "#D67236", color = "black", show.legend = FALSE) +
         labs(title = "Distribución vx (298 K)", x = "vx (nm/ps)", y = "Frecuencia"),
       width = 6, height = 4, dpi = 300)

ggsave("hist_vy_298K.png",
       ggplot(vel, aes(x = vy)) +
         geom_histogram(bins = bins_vy, fill = "#D67236", color = "black", show.legend = FALSE) +
         labs(title = "Distribución vy (298 K)", x = "vy (nm/ps)", y = "Frecuencia"),
       width = 6, height = 4, dpi = 300)

ggsave("hist_vz_298K.png",
       ggplot(vel, aes(x = vz)) +
         geom_histogram(bins = bins_vz, fill = "#D67236", color = "black", show.legend = FALSE) +
         labs(title = "Distribución vz (298 K)", x = "vz (nm/ps)", y = "Frecuencia"),
       width = 6, height = 4, dpi = 300)

clasificar_conformacion <- function(phi, psi) {
  if (phi >= -90 & phi <= -30 & psi >= -70 & psi <= 10) {
    "alpha_R"
  } else if (phi >= -180 & phi <= -90 & psi >= 90 & psi <= 180) {
    "beta"
  } else if (phi >= 30 & phi <= 90 & psi >= 0 & psi <= 90) {
    "alpha_L"
  } else {
    "otros"
  }
}

resultados <- list()

for (res in names(rama_files)) {
  rama <- read.table(rama_files[[res]])
  if (ncol(rama) == 3) {
    colnames(rama) <- c("frame", "phi", "psi")
    rama <- rama[, c("phi", "psi")]
  } else {
    colnames(rama) <- c("phi", "psi")
  }
  rama$conformacion <- mapply(clasificar_conformacion, rama$phi, rama$psi)
  tabla_conf <- prop.table(table(rama$conformacion)) * 100
  resultados[[res]] <- round(tabla_conf, 2)
  
  ggsave(paste0("ramachandran_", res, "_298K.png"),
         ggplot(rama, aes(x = phi, y = psi)) +
           stat_density_2d(aes(fill = after_stat(density)), geom = "raster", contour = FALSE) +
           scale_fill_viridis(option = "magma") +
           labs(title = paste("Ramachandran Plot", res, "(298 K)"),
                x = expression(phi~"(°)"),
                y = expression(psi~"(°)"),
                fill = "Densidad") +
           coord_cartesian(xlim = c(-180, 180), ylim = c(-180, 180)),
         width = 6, height = 5, dpi = 300)
}

sink("reporte_estructural_298K.txt")
cat("ANÁLISIS ESTRUCTURAL – 298 K\n")
cat("Fecha:", as.character(Sys.time()), "\n\n")
cat("Histogramas generados:\n")
cat(" - hist_temperatura_298K.png\n")
cat(" - hist_vx_298K.png\n")
cat(" - hist_vy_298K.png\n")
cat(" - hist_vz_298K.png\n\n")
cat("Ramachandran plots generados:\n")
for (res in names(rama_files)) {
  cat(" - ramachandran_", res, "_298K.png\n", sep = "")
}
cat("\n")
cat("Distribución conformacional (%):\n\n")
for (res in names(resultados)) {
  cat(res, "\n")
  print(resultados[[res]])
  cat("\n")
}
sink()