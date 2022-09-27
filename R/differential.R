normalize_samples = function(lipid_measurements){
  # do normalization in here and return the df
  # tar_load(lipid_measurements)
  numeric_only = lipid_measurements |>
    dplyr::select(-feature_id, -class, -name, -group_units)
  numeric_long = numeric_only |>
    tidyr::pivot_longer(cols = everything(), names_to = "sample", values_to = "abundance")
  med_vals = numeric_long |>
    dplyr::filter(!is.na(abundance)) |>
    dplyr::group_by(sample) |>
    dplyr::summarise(median = median(abundance))
  
  norm_values = purrr::map_dfc(med_vals$sample, function(in_sample){
    use_norm = med_vals |>
      dplyr::filter(sample %in% in_sample) |>
      dplyr::pull(median)
    numeric_only[[in_sample]] / use_norm
  })
  names(norm_values) = med_vals$sample
  
  norm_values$feature_id = lipid_measurements$feature_id
  norm_values
  
}

impute_missing = function(lipid_normalized){
  # do imputation
  # tar_load(lipid_normalized)
  numeric_long = lipid_normalized |>
    tidyr::pivot_longer(cols = -feature_id, names_to = "sample", values_to = "abundance")
  log_dist = log(numeric_long$abundance)
  min_log = min(log_dist, na.rm = TRUE)
  impute_val = exp(min_log + (min_log * 0.1))
  numeric_long$abundance[is.na(numeric_long$abundance)] = impute_val
  
  imputed_data = numeric_long |>
    tidyr::pivot_wider(id_cols = "feature_id", names_from = "sample", values_from = "abundance")
  imputed_data
}

differential_test = function(lipid_imputed, lipid_metadata){
  # do differential test via limma
  # tar_load(lipid_imputed)
  # tar_load(lipid_metadata)
  log_matrix = lipid_imputed |>
    dplyr::select(all_of(lipid_metadata$sample_id)) |>
    as.matrix() |>
    log2()
  rownames(log_matrix) = lipid_imputed$feature_id
  
  lipid_metadata$group_info = factor(lipid_metadata$group_units, levels = c("WT", "KO"), ordered = TRUE)
  design_matrix = model.matrix(~ group_info, lipid_metadata)
  log_fit = limma::lmFit(log_matrix, design = design_matrix)
  log_fit = limma::eBayes(log_fit)
  log_limma = limma::topTable(log_fit, coef = "group_info.L", number = Inf, p.value = 1, sort.by = "none")
  log_limma$feature_id = rownames(log_matrix)
  log_limma
}