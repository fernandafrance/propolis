######################### t-SNE with modifications ##########################

# Set working directory
setwd("C:/Users/ferfr/OneDrive/Documentos/Doutorado/GOOGLE COLAB")

suppressPackageStartupMessages({
  library(tidyverse)
  library(data.table)
  library(ggplot2)
  library(Rtsne)
  library(viridis)
  library(igraph)
  library(ggrepel)
  library(fingerprint)
  library(rcdk)
  library(shadowtext)
  library(forcats)
  library(grid)   # unit() para ajuste da legenda
})

# 1) Importar dataset
df <- fread("washed_with_scaffolds.csv")
df <- df[!is.na(washed) & washed != ""]

# 1b) Anotações químicas (merge por CID)
collapse_mode <- function(x) {
  x <- x[!is.na(x) & nzchar(x)]
  if (length(x) == 0) return(NA_character_)
  names(sort(table(x), decreasing = TRUE))[1]
}

anno <- fread("tabela_completa_com_merge.csv") %>%
  mutate(CID = as.character(CID)) %>%
  select(CID, Superclass, Class, Subclass, `Parent Level 1`, `Parent Level 2`) %>%
  group_by(CID) %>%
  summarise(across(c(Superclass, Class, Subclass, `Parent Level 1`, `Parent Level 2`), collapse_mode),
            .groups = "drop")

df <- df %>%
  mutate(CID = as.character(CID)) %>%
  left_join(anno, by = "CID")

cat("com Subclass anotada:", sum(!is.na(df$Subclass)), "de", nrow(df), "\n")

# 2) SMILES -> moléculas e fingerprints
mols <- parse.smiles(df$washed)
fps  <- lapply(mols, get.fingerprint, type = "extended")

# 3) Matriz de similaridade Tanimoto
sim_matrix <- fp.sim.matrix(fps, method = "tanimoto")

# 4) t-SNE (usando a distância 1 - Tanimoto)
set.seed(42)
tsne <- Rtsne(as.dist(1 - sim_matrix), is_distance = TRUE)
df$TSNE1 <- tsne$Y[,1]
df$TSNE2 <- tsne$Y[,2]

# 5) Arestas para Tanimoto >= 0.8
g <- graph_from_adjacency_matrix(sim_matrix >= 0.8, mode = "undirected", diag = FALSE)
edges <- as_data_frame(g) |>
  rename(from = from, to = to)

df$ID <- seq_len(nrow(df))
edges <- edges |>
  mutate(
    x    = df$TSNE1[from],
    y    = df$TSNE2[from],
    xend = df$TSNE1[to],
    yend = df$TSNE2[to]
  )

# 6) Tamanho das séries (por CRID; no seu caso == por scaffold)
df <- df |>
  group_by(CRID) |>
  mutate(cluster_size = n()) |>
  ungroup()

# 7) SMARTS principais (opcional manter; não altera as cores diretamente)
smarts_present <- function(smarts, mols) {
  vapply(mols, function(m) {
    res <- tryCatch(rcdk::matches(m, smarts), error = function(e) NA)
    if (is.na(res)) res <- tryCatch(rcdk::matches(smarts, m), error = function(e) FALSE)
    isTRUE(res)
  }, logical(1))
}
df$has_benzene     <- smarts_present("c1ccccc1", mols)   # anel aromático de 6C
df$has_cyclohexane <- smarts_present("C1CCCCC1", mols)   # ciclo-hexano alifático
# df$has_ring      <- smarts_present("[R]", mols)        # se quiser voltar ao split por anel

# 8) Heurística textual usando colunas anotadas
ann_cols <- intersect(c("Superclass","Class","Subclass","Parent Level 1","Parent Level 2"), names(df))
if (length(ann_cols) == 0) {
  texto_annot <- rep("", nrow(df))
} else {
  texto_annot <- apply(df[, ann_cols, drop = FALSE], 1, function(x) {
    tolower(paste(na.omit(as.character(x)), collapse = " | "))
  })
}

# Padrões EN/PT
pat_terp  <- "(terpen|terpeno|monoterpen|sesquiterpen|diterpen|sesterterpen|triterpen|tetraterpen|isopren|isopreno|carotenoid|carotenoide|apocarotenoid|limonoid|limonoide)"
pat_flav  <- "(\\bflav|isoflav|neoflav|chalcon(a|e)?|auron(a|e)?|anthocyan|catechin|proanthocyanidin|biflav|flavonol|flavanone|flavone|flavan)"
pat_fatty <- "(fatty ac|fatty acyl|acylglycer|glycerolipid|monoacyl|diacyl|triacyl|triglycer|triacilglicer|glicer|glycer|wax ester|polyol|alditol|sugar alcohol|alcool|álcool)"

is_terpenoid <- grepl(pat_terp,  texto_annot, perl = TRUE)
is_flavonoid <- grepl(pat_flav,  texto_annot, perl = TRUE)
is_fatty     <- grepl(pat_fatty, texto_annot, perl = TRUE)

# 9) Grupo químico (UNIFICADO: sem "linear no ring")
df$ChemGroup <- dplyr::case_when(
  !is.na(df$CRID) & df$CRID == 297 ~ "benzene-related series",
  is_terpenoid                     ~ "Terpenoids",
  is_flavonoid                     ~ "Flavonoids & relatives",
  is_fatty                         ~ "Fatty esters / alcohols / polyols",
  TRUE                             ~ "Other"
)

df$ChemGroup <- factor(df$ChemGroup, levels = c(
  "benzene-related series",
  "Flavonoids & relatives",
  "Terpenoids",
  "Fatty esters / alcohols / polyols",
  "Other"
))

# 10) Paleta fixa (HEX)
col_benzene  <- "#22A884"  # benzene-related series (viridis green)
col_flav     <- "#440154"  # Flavonoids (deep purple)
col_terp     <- "#FDE725"  # Terpenoids (bright yellow)
col_fatty    <- "#B8DE29"  # Fatty/polyols (yellow-green)
col_other    <- "#D3D3D3"  # Other (light gray)

color_map <- c(
  "benzene-related series"            = col_benzene,
  "Flavonoids & relatives"            = col_flav,
  "Terpenoids"                        = col_terp,
  "Fatty esters / alcohols / polyols" = col_fatty,
  "Other"                              = col_other
)

# 11) Subclasses para destaque (HALO + RÓTULO)
subclass_lc <- tolower(dplyr::coalesce(df$Subclass, ""))
df$FocusSubclass <- dplyr::case_when(
  grepl("\\bbenzoic acids? and derivatives?\\b", subclass_lc) ~ "Benzoic acids & derivatives",
  grepl("\\bflavans?\\b", subclass_lc)                       ~ "Flavans",
  grepl("\\bisoindolines?\\b", subclass_lc)                  ~ "Isoindolines",
  grepl("o-?methylated isoflavonoids?", subclass_lc)         ~ "O-methylated isoflavonoids",
  TRUE                                                       ~ NA_character_
)

focus_centroids <- df %>%
  filter(!is.na(FocusSubclass)) %>%
  group_by(FocusSubclass) %>%
  summarise(TSNE1 = median(TSNE1, na.rm = TRUE),
            TSNE2 = median(TSNE2, na.rm = TRUE),
            n = dplyr::n(),
            .groups = "drop")

#######################################
#######################################
#######################################
# 12) Plot (fundo branco, sem título, eixos nomeados, legendas de cor e tamanho)
p <- ggplot(df, aes(x = TSNE1, y = TSNE2)) +
  geom_segment(
    data = edges,
    aes(x = x, y = y, xend = xend, yend = yend),
    color = "#3a3a3a", linewidth = 0.4, alpha = 0.35, inherit.aes = FALSE
  ) +
  # HALO para TODOS os pontos na mesma cor do preenchimento (desenha primeiro)
  geom_point(
    aes(size = cluster_size, color = ChemGroup),
    shape = 21, fill = NA, stroke = 1.4,
    show.legend = FALSE
  ) +
  # Pontos preenchidos com BORDA NA MESMA COR (sem preto)
  geom_point(
    aes(size = cluster_size, fill = ChemGroup, color = ChemGroup),
    shape = 21, stroke = 0.6, alpha = 1
  ) +
  # === BLOCO DE RÓTULOS (pode remover depois) ================================
# Para exportar uma versão SEM rótulos, COMENTE o bloco "LABELS" abaixo.
#geom_shadowtext(
#  data = focus_centroids,
#  aes(x = TSNE1, y = TSNE2, label = paste0(FocusSubclass, " (n=", n, ")")),
#  size = 4, fontface = "bold", color = "black",
#  bg.color = "white", bg.r = 0.24,
#  inherit.aes = FALSE, show.legend = FALSE
#) +
  # === FIM DO BLOCO "LABELS" ================================================
scale_fill_manual(values = color_map, drop = FALSE, name = "Chemical group") +
  scale_color_manual(values = color_map, guide = "none") +   # halos usam mesmas cores do fill
  scale_size(range = c(2, 10), name = "Series size") +
  guides(
    fill = guide_legend(override.aes = list(size = 6))       # bolhas maiores na legenda de cores
  ) +
  theme_classic(base_size = 14) +
  theme(
    legend.position = "bottom",
    legend.key.size = unit(7, "mm"),
    panel.grid = element_blank(),
    plot.title = element_blank()
  ) +
  labs(
    x = "t-SNE dimension 1",
    y = "t-SNE dimension 2"
  )

print(p)
ggsave("constellation_tsne_all_viridis_groups_v9.png", plot = p, dpi = 600, width = 20, height = 14)
