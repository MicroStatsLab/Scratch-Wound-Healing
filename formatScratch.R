formatScratch <- function(results){

  # first remove the first column
  results_df <- results[-1]

  # split "Label" into different columns for the Image/File name and the ROI numbers
  results_df <- results_df %>%
    separate(Label, into = c("Label", "ROI"), sep = ".jpg", extra = "merge") %>%
    mutate(Label = paste0(Label, ".jpg")) %>%
    select(-ROI)

  # sum the data for those that had multiple ROI measurements
  formatScratch <- results_df %>%
    group_by(Label) %>%
    summarize(across(where(is.numeric), sum, na.rm = TRUE))

  # split Label into different columns for Replicate #, Day #, and Image #
  namesdf <- data.frame(Label = formatScratch$Label) %>%
    separate(Label, into = c("Strain", "Replicate", "Day", "Image"), sep = "_") %>%
    separate(Image, into = c("Remove1", "Image", "Remove2")) %>%
    separate(Day, into = c("Remove3", "Day"), sep = "Day") %>%
    select(-Remove1, -Remove2, -Remove3)

  # combines namesdf into formatScratch, and reorganizes columns
  formatScratch <- formatScratch %>%
    cbind(namesdf) %>%
    select(Label, Strain, Replicate, Day, Image, everything())

  # outputs the new data frame back into a .csv file
  fileName <- file.path(getwd(), "Scratch_Assay_Results.csv")
  write.csv(formatScratch, fileName, row.names=FALSE)
}
