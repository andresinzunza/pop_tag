# PACKAGES ----

library(readxl)
library(dplyr)
library(metafor)
library(ggplot2)

# LOAD DATA ----

data_full <- read_excel(
  "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx",
  sheet = "combined"
)

# META FUNCTION ----

run_meta <- function(df, yi, sei) {
  metafor::rma(
    yi = df[[yi]],
    sei = df[[sei]],
    method = "REML"
  )
}

extract_results <- function(model, name) {
  data.frame(
    Scenario = name,
    Estimate = as.numeric(model$b),
    CI_lower = model$ci.lb,
    CI_upper = model$ci.ub,
    SE = model$se,
    I2 = model$I2
  )
}


# 1.00 ANALYSIS 1 — TIME-----------

# DATA PREPARATION ----

data_time <- data_full %>%
  filter(
    !is.na(duration_min_mrf),
    !is.na(dis_duration_min_mrf),
    !is.na(duration_min_hfa),
    !is.na(dis_duration_min_hfa),
    !is.na(n_eyes),
    !is.na(two_eye_study)
  ) %>%
  mutate(
    diff_time = duration_min_mrf - duration_min_hfa,
    se_base = sqrt(
      (dis_duration_min_mrf^2)/n_eyes +
        (dis_duration_min_hfa^2)/n_eyes
    )
  )

# SENSITIVITY SCENARIOS ----

data_time <- data_time %>%
  mutate(
    se_S1 = se_base,
    se_S2 = ifelse(two_eye_study == 1, se_base * 1.14, se_base),
    se_S3 = ifelse(two_eye_study == 1, se_base * 1.22, se_base),
    se_S4 = ifelse(two_eye_study == 1, se_base * 1.30, se_base),
    se_S6 = ifelse(two_eye_study == 1, se_base * 1.41, se_base)
  )

# META ANALYSIS ----

res_time_S1 <- run_meta(data_time, "diff_time", "se_S1")
res_time_S2 <- run_meta(data_time, "diff_time", "se_S2")
res_time_S3 <- run_meta(data_time, "diff_time", "se_S3")
res_time_S4 <- run_meta(data_time, "diff_time", "se_S4")
res_time_S5 <- run_meta(filter(data_time, two_eye_study == 0), "diff_time", "se_S1")
res_time_S6 <- run_meta(data_time, "diff_time", "se_S6")

# RESULTS ----

results_time <- bind_rows(
  extract_results(res_time_S1, "S1: No penalty"),
  extract_results(res_time_S2, "S2: ρ=0.3"),
  extract_results(res_time_S3, "S3: ρ=0.5"),
  extract_results(res_time_S4, "S4: ρ=0.7"),
  extract_results(res_time_S5, "S5: Single-eye only"),
  extract_results(res_time_S6, "S6: ρ=1.0")
)

print(results_time)

#GGPLOT-----

plot_time <- results_time %>%
  mutate(
    Scenario = factor(Scenario, levels = rev(Scenario)),
    label = sprintf("%.2f [%.2f, %.2f]", Estimate, CI_lower, CI_upper),
    y_pos = as.numeric(Scenario)
  )

x_lim <- ceiling(max(abs(plot_time$CI_lower), abs(plot_time$CI_upper)))

ggplot(plot_time, aes(x = Estimate, y = Scenario)) +
  geom_errorbarh(aes(xmin = CI_lower, xmax = CI_upper), height = 0.2, linewidth = 0.9) +
  geom_point(size = 3, shape = 15) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 1) +
  
  # 👉 place labels slightly ABOVE each point
  geom_text(
    aes(x = Estimate, y = y_pos + 0.25, label = label),
    size = 4,
    fontface = "bold"
  ) +
  
  scale_x_continuous(limits = c(-x_lim, x_lim)) +
  labs(
    x = "Difference in Testing Time (minutes, MRF − HFA)",
    y = NULL,
    title = "Sensitivity Analysis: Inter-Eye Correlation (Time)"
  ) +
  theme_minimal(base_size = 14)




# ANALYSIS 2 — MD---------


# DATA PREPARATION ----

data_md <- data_full %>%
  filter(
    !is.na(mean_md_mrf),
    !is.na(mean_md_hfa),
    !is.na(disp_mean_md_mrf),
    !is.na(disp_mean_md_hfa),
    !is.na(n_eyes),
    !is.na(two_eye_study)
  ) %>%
  filter(study_id != "Kang, 2023") %>%
  mutate(
    diff_md = mean_md_mrf - mean_md_hfa,
    se_base = sqrt(
      (disp_mean_md_mrf^2 + disp_mean_md_hfa^2 -
         2 * 0.8 * disp_mean_md_mrf * disp_mean_md_hfa) / n_eyes
    )
  )

# SENSITIVITY SCENARIOS ----

data_md <- data_md %>%
  mutate(
    se_S1 = se_base,
    se_S2 = ifelse(two_eye_study == 1, se_base * 1.14, se_base),
    se_S3 = ifelse(two_eye_study == 1, se_base * 1.22, se_base),
    se_S4 = ifelse(two_eye_study == 1, se_base * 1.30, se_base),
    se_S6 = ifelse(two_eye_study == 1, se_base * 1.41, se_base)
  )

# META ANALYSIS ----

res_md_S1 <- run_meta(data_md, "diff_md", "se_S1")
res_md_S2 <- run_meta(data_md, "diff_md", "se_S2")
res_md_S3 <- run_meta(data_md, "diff_md", "se_S3")
res_md_S4 <- run_meta(data_md, "diff_md", "se_S4")
res_md_S5 <- run_meta(filter(data_md, two_eye_study == 0), "diff_md", "se_S1")
res_md_S6 <- run_meta(data_md, "diff_md", "se_S6")

# RESULTS ----

results_md <- bind_rows(
  extract_results(res_md_S1, "S1: No penalty"),
  extract_results(res_md_S2, "S2: ρ=0.3"),
  extract_results(res_md_S3, "S3: ρ=0.5"),
  extract_results(res_md_S4, "S4: ρ=0.7"),
  extract_results(res_md_S5, "S5: Single-eye only"),
  extract_results(res_md_S6, "S6: ρ=1.0")
)

print(results_md)


# GGPLOT ----

plot_md <- results_md %>%
  mutate(
    Scenario = factor(Scenario, levels = rev(Scenario)),
    label = sprintf("%.2f [%.2f, %.2f]", Estimate, CI_lower, CI_upper),
    y_pos = as.numeric(Scenario)
  )

x_lim_md <- ceiling(max(abs(plot_md$CI_lower), abs(plot_md$CI_upper)))

ggplot(plot_md, aes(x = Estimate, y = Scenario)) +
  geom_errorbarh(aes(xmin = CI_lower, xmax = CI_upper), height = 0.2, linewidth = 0.9) +
  geom_point(size = 3, shape = 15) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 1) +
  
  # 👉 FIX: move labels above each point
  geom_text(
    aes(x = Estimate, y = y_pos + 0.25, label = label),
    size = 4,
    fontface = "bold"
  ) +
  
  scale_x_continuous(limits = c(-x_lim_md, x_lim_md)) +
  labs(
    x = "Mean Difference (dB, MRF − HFA)",
    y = NULL,
    title = "Sensitivity Analysis: Inter-Eye Correlation (MD)"
  ) +
  theme_minimal(base_size = 14)


# 3.0 PSD------

# DATA PREPARATION ----

data_psd <- data_full %>%
  filter(
    !is.na(mean_psd_mrf),
    !is.na(mean_psd_hfa),
    !is.na(disp_mean_psd_mrf),
    !is.na(disp_mean_psd_hfa),
    !is.na(n_eyes),
    !is.na(two_eye_study)
  ) %>%
  mutate(
    diff_psd = mean_psd_mrf - mean_psd_hfa,
    se_base = sqrt(
      (disp_mean_psd_mrf^2 + disp_mean_psd_hfa^2 -
         2 * 0.8 * disp_mean_psd_mrf * disp_mean_psd_hfa) / n_eyes
    )
  )

# SENSITIVITY SCENARIOS ----

data_psd <- data_psd %>%
  mutate(
    se_S1 = se_base,
    se_S2 = ifelse(two_eye_study == 1, se_base * 1.14, se_base),
    se_S3 = ifelse(two_eye_study == 1, se_base * 1.22, se_base),
    se_S4 = ifelse(two_eye_study == 1, se_base * 1.30, se_base),
    se_S6 = ifelse(two_eye_study == 1, se_base * 1.41, se_base)
  )

# META ANALYSIS ----

res_psd_S1 <- run_meta(data_psd, "diff_psd", "se_S1")
res_psd_S2 <- run_meta(data_psd, "diff_psd", "se_S2")
res_psd_S3 <- run_meta(data_psd, "diff_psd", "se_S3")
res_psd_S4 <- run_meta(data_psd, "diff_psd", "se_S4")
res_psd_S5 <- run_meta(filter(data_psd, two_eye_study == 0), "diff_psd", "se_S1")
res_psd_S6 <- run_meta(data_psd, "diff_psd", "se_S6")

# RESULTS ----

results_psd <- bind_rows(
  extract_results(res_psd_S1, "S1: No penalty"),
  extract_results(res_psd_S2, "S2: ρ=0.3"),
  extract_results(res_psd_S3, "S3: ρ=0.5"),
  extract_results(res_psd_S4, "S4: ρ=0.7"),
  extract_results(res_psd_S5, "S5: Single-eye only"),
  extract_results(res_psd_S6, "S6: ρ=1.0")
)

print(results_psd)


# GGPLOT ----

plot_psd <- results_psd %>%
  mutate(
    Scenario = factor(Scenario, levels = rev(Scenario)),
    label = sprintf("%.2f [%.2f, %.2f]", Estimate, CI_lower, CI_upper),
    y_pos = as.numeric(Scenario)
  )

x_lim_psd <- ceiling(max(abs(plot_psd$CI_lower), abs(plot_psd$CI_upper)))
ggplot(plot_psd, aes(x = Estimate, y = Scenario)) +
  geom_errorbarh(aes(xmin = CI_lower, xmax = CI_upper), height = 0.2, linewidth = 0.9) +
  geom_point(size = 3, shape = 15) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 1) +
  geom_text(
    aes(x = Estimate, y = y_pos + 0.25, label = label),
    size = 4,
    fontface = "bold"
  ) +
  scale_x_continuous(limits = c(-x_lim_psd, x_lim_psd)) +
  labs(
    x = "Mean Difference (dB, MRF − HFA)",
    y = NULL,
    title = "Sensitivity Analysis: Inter-Eye Correlation (PSD)"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold")
  )