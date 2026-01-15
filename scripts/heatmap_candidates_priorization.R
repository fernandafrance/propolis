####### novas figuras

# Set working directory
setwd("C:/Users/ferfr/OneDrive/Documentos/Doutorado/GOOGLE COLAB")

# 📦 Instalar e carregar pacotes necessários
#packages <- c("ggplot2", "dplyr", "reshape2", "GGally", "scales", "ggforce", "plotly", "readr", "tidyr", "fmsb", "FactoMineR", "factoextra", "networkD3")
#invisible(lapply(packages, function(x) if (!require(x, character.only = TRUE)) install.packages(x)))
#lapply(packages, library, character.only = TRUE)
library(readr)
library(ggplot2)
library(dplyr)
library(reshape2)
library(GGally)
library(scales)
library(ggforce)
library(plotly)
library(tidyr)
library(fmsb)
library(FactoMineR)
library(factoextra)
library(networkD3)
library(dplyr)


# 📂 Carregar os dados
file <- "planilha_input_new_diagram_subclass.csv"
dados <- read_csv(file)
dados <- dados[-8,]

# 🧼 Selecionar colunas de interesse
df <- dados %>%
  select(`Compound Name`, `Affinity (kcal/mol)`, `Ligand Effiency`, `Tanimoto similarity`, `Drug-like?`, Subclass)

# Renomear para facilitar
df <- df %>%
  rename(Compound = `Compound Name`,
         Affinity = `Affinity (kcal/mol)`,
         Efficiency = `Ligand Effiency`,
         Similarity = `Tanimoto similarity`,
         DrugLike = `Drug-like?`)

# Paleta pastel ou viridis adaptada
library(viridis)
#### Heatmap com ComplexHeatmaps
# 📦 Pacotes

library(ComplexHeatmap)
library(circlize)
library(grid)
library(dplyr)
library(tibble)
library(viridis)

# Dados com z-score
heat_data <- df %>%
  select(Compound, Affinity, Efficiency, Similarity, DrugLike, Subclass) %>%
  mutate(
    Affinity = scale(Affinity)[,1],
    Efficiency = scale(Efficiency)[,1]
  ) %>%
  column_to_rownames("Compound")

heat_data$Affinity <- scale(-df$Affinity)[,1]
heat_data$Efficiency <- scale(-df$Efficiency)[,1]



heat_matrix <- as.matrix(heat_data[, c("Affinity", "Efficiency")])

# Paleta pastel personalizada para o heatmap
my_pastel_gradient <- colorRamp2(c(-2, 0, 2), c("#FFFFCC", "#99D8C9", "#6A51A3"))

# Cores para DrugLike
druglike_colors <- c("green" = "#1A9850", "yellow" = "#FEE08B", "red" = "#D73027")

# Cores para Subclass com viridis_d
subclass_levels <- unique(df$Subclass)
subclass_colors <- setNames(viridis(length(subclass_levels), option = "D"), subclass_levels)

# Anotações
ha <- rowAnnotation(
  DrugLike = heat_data$DrugLike,
  Similarity = heat_data$Similarity,
  Subclass = heat_data$Subclass,
  col = list(
    DrugLike = druglike_colors,
    Subclass = subclass_colors
  ),
  annotation_name_side = "top",
  annotation_name_rot = 90,
  annotation_legend_param = list(
    DrugLike = list(title = "Drug-likeness"),
    Similarity = list(title = "Tanimoto"),
    Subclass = list(title = "Chemical Subclass")
  )
)

# Heatmap com paleta pastel personalizada
ht <- Heatmap(
  heat_matrix,
  name = "z-score",
  col = my_pastel_gradient,
  right_annotation = ha,
  cluster_rows = TRUE,
  cluster_columns = TRUE,
  show_row_names = TRUE,
  show_column_names = TRUE,
  row_names_gp = gpar(fontsize = 8),
  column_names_gp = gpar(fontsize = 10),
  column_title = "Affinity & Efficiency (z-score)"
)

# Exportar para PDF com legenda correta
pdf("complex_heatmap_affinity_efficiency_janeiro_1.pdf", width = 10, height = 8)
draw(ht, heatmap_legend_side = "right", annotation_legend_side = "right", merge_legend = FALSE)
dev.off()

##### versão com subclass em cinza
# 📦 Pacotes
library(ComplexHeatmap)
library(circlize)
library(grid)
library(dplyr)
library(tibble)
library(RColorBrewer)

# 1. Preparar dados
heat_data <- df %>%
  select(Compound, Affinity, Efficiency, Similarity, DrugLike, Subclass) %>%
  column_to_rownames("Compound")

# Inverter os valores para z-score: quanto mais negativo, melhor
heat_data$Affinity <- scale(df$Affinity)
heat_data$Efficiency <- scale(df$Efficiency)

# 2. Matriz principal
heat_matrix <- as.matrix(heat_data[, c("Affinity", "Efficiency")])

# 3. Paleta pastel personalizada (como solicitado)
my_pastel_gradient <- colorRamp2(
  c(-2, 0, 2),
  c("#FFFFCC", "#99D8C9", "#6A51A3")
)

# 4. Paleta para Similarity (continua) com YellowGreenBlue
# Paleta para Similarity com 3 cores (YlGnBu)
similarity_breaks <- quantile(heat_data$Similarity, probs = c(0, 0.5, 1), na.rm = TRUE)
similarity_colors <- colorRamp2(
  similarity_breaks,
  brewer.pal(9, "YlGnBu")[c(3, 6, 9)]
)


# 5. Paleta para Subclass em cinza
subclass_levels <- unique(df$Subclass)
subclass_colors_gray <- setNames(
  gray.colors(length(subclass_levels), start = 0.9, end = 0.2),
  subclass_levels
)

# 6. Cores para DrugLike
druglike_colors <- c("green" = "#1A9850", "yellow" = "#FEE08B", "red" = "#D73027")

# 7. Anotações
ha_gray <- rowAnnotation(
  DrugLike = heat_data$DrugLike,
  Similarity = heat_data$Similarity,
  Subclass = heat_data$Subclass,
  col = list(
    DrugLike = druglike_colors,
    Similarity = similarity_colors,
    Subclass = subclass_colors_gray
  ),
  annotation_name_side = "top",
  annotation_name_rot = 90,
  annotation_legend_param = list(
    DrugLike = list(title = "Drug-likeness"),
    Similarity = list(title = "Tanimoto"),
    Subclass = list(title = "Chemical Subclass")
  )
)

# 8. Criar heatmap com paleta pastel e anotações ajustadas
ht_gray <- Heatmap(
  heat_matrix,
  name = "z-score",
  col = my_pastel_gradient,
  right_annotation = ha_gray,
  cluster_rows = TRUE,
  cluster_columns = TRUE,
  show_row_names = TRUE,
  show_column_names = TRUE,
  row_names_gp = gpar(fontsize = 8),
  column_names_gp = gpar(fontsize = 10),
  column_title = "Affinity & Efficiency (z-score)"
)

# 9. Exportar como PDF com renderização completa
pdf("complex_heatmap_affinity_efficiency_final_janeiro_2.pdf", width = 10, height = 8)
draw(ht_gray, heatmap_legend_side = "right", annotation_legend_side = "right", merge_legend = FALSE)
dev.off()

##### Fixar subclasses
ht_gray <- Heatmap(
  heat_matrix,
  name = "z-score",
  col = my_pastel_gradient,
  right_annotation = ha_gray,
  cluster_rows = TRUE,
  cluster_columns = TRUE,
  row_split = heat_data$Subclass,  # 👈 agrupamento por Subclass
  show_row_names = TRUE,
  show_column_names = TRUE,
  row_names_gp = gpar(fontsize = 8),
  column_names_gp = gpar(fontsize = 10),
  column_title = "Affinity & Efficiency (z-score)"
)
# 9. Exportar como PDF com renderização completa
pdf("complex_heatmap_affinity_efficiency_subclass-fixa_novo.pdf", width = 10, height = 8)
draw(ht_gray, heatmap_legend_side = "right", annotation_legend_side = "right", merge_legend = FALSE)
dev.off()