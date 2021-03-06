#!/usr/bin/env Rscript
#
# Copyright 2014 Google Inc. All rights reserved.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Simple tool that wraps the analysis/R library.
#
# To run this you need:
# - ggplot
# - optparse
# - glmnet -- dependency of analysis library

library(optparse)

# Do command line parsing first to catch errors.  Loading libraries in R is
# slow.
if (!interactive()) {
  option_list <- list(
     make_option(c("-t", "--title"), help="Plot Title")
     )
  parsed <- parse_args(OptionParser(option_list = option_list),
                       positional_arguments = 2)  # input and output
}

library(ggplot2)

# Use CairoPNG if available.  Useful for headless R.
if (library(Cairo, quietly = TRUE, logical.return = TRUE)) {
  png_func = CairoPNG
  cat('Using CairoPNG\n')
} else {
  png_func = png
  cat('Using png\n')
}

source("analysis/R/analysis_lib.R")
source("analysis/R/read_input.R")
source("analysis/R/decode.R")

source("analysis/R/alternative.R")  # temporary

Log <- function(...) {
  cat('analyze.R: ')
  cat(sprintf(...))
  cat('\n')
}

LoadInputs <- function(prefix, ctx) {
  # prefix: path prefix, e.g. '_tmp/exp'
  p <- paste0(prefix, '_params.csv')
  c <- paste0(prefix, '_counts.csv')
  m <- paste0(prefix, '_map.csv')
  h <- paste0(prefix, '_hist.csv')

  params <- ReadParameterFile(p)
  counts <- ReadCountsFile(c)
  map <- ReadMapFile(m)

  # Calls AnalyzeRAPPOR to run the analysis code
  rappor <- AnalyzeRAPPOR(params, counts, map$map, "FDR", 0.05,
                          date="01/01/01", date_num="100001")
  if (is.null(rappor)) {
    stop("RAPPOR analysis failed.")
  }

  Log("Analysis Results:")
  str(rappor)

  Log("sum(proportion)")
  print(sum(rappor$proportion))

  Log("sum(estimate)")
  print(sum(rappor$estimate))

  ctx$rappor <- rappor
  ctx$actual <- read.csv(h)
}

# Prepare input data to be plotted
ProcessAll = function(ctx) {
  actual <- ctx$actual
  rappor <- ctx$rappor

  # "s12" -> 12, for graphing
  StringToInt <- function(x) as.integer(substring(x, 2))

  total <- sum(actual$count)
  a <- data.frame(index = StringToInt(actual$string),
                  # Calculate the true proportion
                  proportion = actual$count / total,
                  dist = "actual")

  r <- data.frame(index = StringToInt(rappor$strings),
                  proportion = rappor$proportion,
                  dist = "rappor")
  
  # L1 distance between actual and rappor distributions
  # Outer join
  merged <- merge(r[,c('index', 'proportion')],
                  a[,c('index', 'proportion')],
                  by='index', all=TRUE)
  # NA values set to 0.0
  merged[is.na(merged)] <- 0
  l1 <- sum(abs(merged$proportion.x - merged$proportion.y))
  
  # Fill in zeros for values missing in RAPPOR and in actual data
  # Helps with false positive detection and makes the ggplot look better
  not_in_rappor <- setdiff(actual$string, rappor$strings)
  not_in_actual <- setdiff(rappor$strings, actual$string)
  if (length(not_in_rappor) > 0) {
    z <- data.frame(index = StringToInt(not_in_rappor),
                    proportion = 0.0,
                    dist = "rappor")
    r <- rbind(r, z)
  }
  if (length(not_in_actual) > 0) {
    # More strings detected in RAPPOR than present in actual distr
    # These strings must be reported as false positives in metrics$fp
    z <- data.frame(index = StringToInt(not_in_actual),
                    proportion = 0.0,
                    dist = "actual")
    a <- rbind(a, z)
  }
  
  # Choose false positive strings and their proportion from rappor estimates
  fp <- rappor[rappor$strings %in% not_in_actual,
                      c('strings', 'proportion')]
  metrics <- list(l1 = l1, fp = fp)
  Log("Metrics:")
  print(str(metrics))
  
  # Return data for plots and calculated metrics
  list(plot_data = rbind(r, a), metrics = metrics)
}

# Colors selected to be friendly to the color blind:
# http://www.cookbook-r.com/Graphs/Colors_%28ggplot2%29/
palette <- c("#E69F00", "#56B4E9")

PlotAll <- function(d, title) {
  # NOTE: geom_bar makes a histogram by default; need stat = "identity"
  g <- ggplot(d, aes(x = index, y = proportion, fill = factor(dist)))
  b <- geom_bar(stat = "identity", width = 0.7,
                position = position_dodge(width = 0.8))
  t <- ggtitle(title)
  g + b + t + scale_fill_manual(values=palette)
}

WritePlot <- function(p, outdir, width = 800, height = 600) {
  filename <- file.path(outdir, 'dist.png')
  png_func(filename, width=width, height=height)
  plot(p)
  dev.off()
  Log('Wrote %s', filename)
}

main <- function(parsed) {
  args <- parsed$args
  options <- parsed$options

  input_prefix <- args[[1]]
  output_dir <- args[[2]]

  # increase ggplot font size globally
  theme_set(theme_grey(base_size = 16))

  ctx <- new.env()

  # NOTE: It takes more than 2000+ ms to get here, while the analysis only
  # takes 500 ms or so (as measured by system.time).

  LoadInputs(input_prefix, ctx)
  d <- ProcessAll(ctx)
  p <- PlotAll(d$plot_data, options$title)
  WritePlot(p, output_dir)
}

if (!interactive()) {
  main(parsed)
}
