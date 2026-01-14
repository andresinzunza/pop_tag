
# QUADAS-2 Traffic-Light Plot
## January 14, 2026
## POP-TAG META-ANALYSIS
##Perimetric Outcomes of Melbourne Rapid Field Perimetry in Patients with Glaucoma: A Systematic Review and Meta-Analysis

#---Dependencies and Packages-----

library(tidyverse)
library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(forcats)

# ---- Load data ----
df <- read_csv("/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/risk_of_bias/risk_of_bias_pop_tag/csv_risk_of_bias.csv", show_col_types = FALSE)

# ---- Cleaning ----

df <- df %>%
  select(
    study_title, study_id, year,
    patient_selection, index_testing, reference_standard, flow_and_time,
    app_patient_selection, app_index_test, app_reference_satandard
  ) %>% drop_na()

# ----  Normalization ----
normalize_quadas <- function(x) {
  z <- tolower(str_trim(as.character(x)))
  z[z %in% c("", "na", "n/a", "null")] <- NA
  
  case_when(
    z == "low" ~ "Low",
    z == "unclear" ~ "Unclear",
    z == "high" ~ "High",
    TRUE ~ NA_character_
  )
}

rob_cols <- c("patient_selection", "index_testing", "reference_standard", "flow_and_time")
app_cols <- c("app_patient_selection", "app_index_test", "app_reference_satandard")
domain_cols <- c(rob_cols, app_cols)

# ---- Long format ----
df_long <- df %>%
  mutate(across(all_of(domain_cols), normalize_quadas)) %>%
  mutate(
    study_label = paste0(study_id, " (", year, ")")
  ) %>%
  select(study_label, year, all_of(domain_cols)) %>%
  pivot_longer(
    cols = all_of(domain_cols),
    names_to = "domain",
    values_to = "judgement"
  ) %>%
  mutate(
    domain_pretty = case_when(
      domain == "patient_selection" ~ "RoB: Patient selection",
      domain == "index_testing" ~ "RoB: Index test",
      domain == "reference_standard" ~ "RoB: Reference standard",
      domain == "flow_and_time" ~ "RoB: Flow & timing",
      domain == "app_patient_selection" ~ "App: Patient selection",
      domain == "app_index_test" ~ "App: Index test",
      domain == "app_reference_satandard" ~ "App: Reference standard",
      TRUE ~ domain
    ),
    domain_pretty = factor(
      domain_pretty,
      levels = c(
        "RoB: Patient selection",
        "RoB: Index test",
        "RoB: Reference standard",
        "RoB: Flow & timing",
        "App: Patient selection",
        "App: Index test",
        "App: Reference standard"
      )
    ),
    judgement = factor(judgement, levels = c("Low", "Unclear", "High"))
  ) %>%
  arrange(year, study_label) %>%
  mutate(study_label = fct_rev(fct_inorder(study_label)))

# ---- GGPlot ----
p <- ggplot(df_long, aes(x = domain_pretty, y = study_label, fill = judgement)) +
  geom_tile(color = "white", linewidth = 0.6) +
  scale_fill_manual(
    values = c("Low" = "#2ECC71", "Unclear" = "#F1C40F", "High" = "#E74C3C"),
    na.value = "grey90",
    drop = FALSE
  ) +
  labs(
    x = NULL,
    y = NULL,
    fill = NULL,
    title = "QUADAS-2 Summary (Risk of Bias & Applicability)"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 30, hjust = 1, vjust = 1),
    axis.text.y = element_text(size = 9),
    plot.title = element_text(face = "bold"),
    legend.position = "top"
  )

print(p)


##---------------GGSave Plot ---------------

ggsave("quadas2_traffic_light.png", p, width = 11, height = 7, dpi = 300)
ggsave("quadas2_traffic_light.pdf", p, width = 11, height = 7)
