### Gerar a matrix de similaridade e criar heatmap
### comparar epi-drugs conhecidas com os compostos da própolis usando cutoff de maior ou igual a 0.4 tanimotto ####

# Set working directory
setwd("C:/Users/ferfr/OneDrive/Documentos/Doutorado/GOOGLE COLAB")

# 📦 Instalar pacote necessário (se ainda não tiver)
if (!require("pheatmap")) install.packages("pheatmap")
library(pheatmap)

# 📂 Ler o arquivo CSV no formato longo
dados <- read.csv("similaridade_fingerprint_input_para_matrix.csv")

# 🔎 Filtro para similaridade de Tanimoto ≥ 0.4
dados_filtrados <- subset(dados, Similaridade_Tanimoto >= 0.4)

# 🧱 Gerar matriz de similaridade (pivot)
library(reshape2)
matriz <- dcast(
  dados_filtrados,
  ID_Candidato ~ Nome_Fármaco,
  value.var = "Similaridade_Tanimoto",
  fun.aggregate = mean
)

# 🔢 Transformar o ID_Candidato em rownames
rownames(matriz) <- matriz$ID_Candidato
matriz$ID_Candidato <- NULL

# 🧼 Remover colunas e linhas vazias
matriz <- matriz[rowSums(is.na(matriz)) != ncol(matriz), ]
matriz <- matriz[, colSums(is.na(matriz)) != nrow(matriz)]

# 🧪 Substituir NAs restantes por zero
matriz[is.na(matriz)] <- 0

# 🎨 Paleta personalizada
cores <- colorRampPalette(c("#FFFFCC", "#C2E699", "#99D8C9", "#8C96C6", "#6A51A3"))(100)

# 🔥 Gerar heatmap com clusterização Euclidean + Complete
pheatmap(
  matriz,
  clustering_distance_rows = "euclidean",
  clustering_distance_cols = "euclidean",
  clustering_method = "complete",
  color = cores,
  main = "Tanimoto Similarity between Candidate Compounds and Literature-Reported Epigenetic Drugs",
  fontsize_row = 6,
  fontsize_col = 6,
  border_color = NA,
  filename = "tanimoto_similarity_heatmap.png",  # 🔽 Exportação automática
  width = 10, height = 10, dpi = 600
)

#### Plot alternativo sem título e maior
pheatmap(
  matriz,
  clustering_distance_rows = "euclidean",
  clustering_distance_cols = "euclidean",
  clustering_method = "complete",
  color = cores,
  border_color = NA, 
  fontsize_row = 3,  # 🔠 tamanho da fonte dos rótulos das linhas
  fontsize_col = 3,  # 🔠 tamanho da fonte dos rótulos das colunas
  angle_col = 0,     # rótulos das colunas na horizontal
  filename = "tanimoto_similarity_heatmap_2.png",  # 🔽 Exportação automática
  width = 8, height = 9, dpi = 900
)


######## Criar segundo gráfico sem PAINS
library(readxl)

dock_df <- read_excel("pains_removed_absent_chemical_groups_removed_docking_ligands.xlsx")

# 🧱 Gerar matriz de similaridade (pivot)
library(reshape2)
matriz <- dcast(
  dock_df,
  CID_candidate ~ CID_reference,
  value.var = "Similaridade_Tanimoto",
  fun.aggregate = mean
)

# 🔢 Transformar o ID_Candidato em rownames
rownames(matriz) <- matriz$CID_candidate
matriz$CID_candidate <- NULL

# 🧼 Remover colunas e linhas vazias
matriz <- matriz[rowSums(is.na(matriz)) != ncol(matriz), ]
matriz <- matriz[, colSums(is.na(matriz)) != nrow(matriz)]

# 🧪 Substituir NAs restantes por zero
matriz[is.na(matriz)] <- 0

# 🎨 Paleta personalizada
cores <- colorRampPalette(c("#FFFFCC", "#C2E699", "#99D8C9", "#8C96C6", "#6A51A3"))(100)

pheatmap(
  matriz,
  clustering_distance_rows = "euclidean",
  clustering_distance_cols = "euclidean",
  clustering_method = "complete",
  color = cores,
  border_color = NA, 
  fontsize_row = 8,  # 🔠 tamanho da fonte dos rótulos das linhas
  fontsize_col = 8,  # 🔠 tamanho da fonte dos rótulos das colunas
  angle_col = 0,     # rótulos das colunas na horizontal
  filename = "tanimoto_similarity_heatmap_dock_df.png",  # 🔽 Exportação automática
  width = 8, height = 9, dpi = 900
)