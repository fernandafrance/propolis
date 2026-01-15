#### Gráfico "rosquinha"
setwd("C:/Users/ferfr/OneDrive/Documentos/Doutorado/Manuscrito propolis compounds/TestingR")

# Carregar pacotes necessários
library(ggplot2)
library(readr)
library(dplyr)

# Ler o arquivo CSV
df <- read_csv("classification_pc.csv")

# Substituir valores NA por "Unclassified"
df[is.na(df)] <- "Unclassified"

# Função para criar gráfico de ROSQUINHA (doughnut)
create_doughnut_plot <- function(df, column, title) {
  # Contar frequência de cada categoria
  data_count <- df %>%
    count(!!sym(column), name = "Frequency") %>%
    mutate(Percentage = Frequency / sum(Frequency) * 100) %>%
    arrange(desc(Frequency))
  
  # Selecionar as top 5 categorias reais (excluindo "Other")
  top_5 <- data_count %>%
    filter(!!sym(column) != "Unclassified") %>%
    slice_max(Frequency, n = 5) %>%
    pull(!!sym(column))
  
  # Criar nova coluna para identificar categorias (top 5 ou "Other")
  data_count <- data_count %>%
    mutate(Category = ifelse(!!sym(column) %in% top_5, !!sym(column), "Other")) %>%
    group_by(Category) %>%
    summarise(Frequency = sum(Frequency)) %>%
    mutate(Percentage = Frequency / sum(Frequency) * 100) %>%
    arrange(desc(Frequency))
  
  # Converter Category para fator ordenado
  data_count$Category <- factor(data_count$Category, levels = c(setdiff(data_count$Category, "Other"), "Other"))
  
  # Definir cores manualmente
  predefined_colors <- c("#fde725", "#b5de2b", "#1f9e89", "#31688e", "#482878")  # 5 cores principais
  categories <- levels(data_count$Category)
  
  # Criar mapeamento de cores, garantindo que "Other" sempre seja "lightgray"
  color_map <- setNames(
    c(predefined_colors[1:(length(categories)-1)], "lightgray"),
    categories
  )
  
  # Criar o gráfico de rosquinha
  ggplot(data_count, aes(x = 2, y = Frequency, fill = Category)) +  # x = 2 cria o buraco no meio
    geom_bar(stat = "identity", width = 1, color = "white") +  # Barras preenchidas
    coord_polar("y", start = 0) +  # Efeito circular
    scale_fill_manual(values = color_map) +  # Aplicar paleta de cores
    geom_text(aes(label = ifelse(Percentage > 3, paste0(round(Percentage, 1), "%"), "")),
              position = position_stack(vjust = 0.5), size = 4) +  # Mostrar % dentro do gráfico
    xlim(1, 3) +  # Ajuste para criar buraco no meio (rosquinha)
    labs(title = title, fill = column) +
    theme_void() +  # Remove eixos e fundo
    theme(legend.position = "right")  # Legenda à direita
}

# Criar os 3 gráficos de rosquinha (doughnut)
plot_superclass <- create_doughnut_plot(df, "Superclass", "Top 5 Superclasses")
plot_class <- create_doughnut_plot(df, "Class", "Top 5 Classes")
plot_subclass <- create_doughnut_plot(df, "Subclass", "Top 5 Subclasses")

# Exibir os gráficos
print(plot_superclass)
print(plot_class)
print(plot_subclass)

# Salvar os gráficos
ggsave("plot_superclass.png", plot = plot_superclass, dpi = 600, width = 10, height = 7)
ggsave("plot_class.png", plot = plot_class, dpi = 600, width = 10, height = 7)
ggsave("plot_subclass.png", plot = plot_subclass, dpi = 600, width = 10, height = 7)
