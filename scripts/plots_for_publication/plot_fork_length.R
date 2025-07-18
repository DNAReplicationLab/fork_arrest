require(ggplot2)
require(ggthemes)
require(scales)
options(bitmapType = "cairo")

# goal of program
# ===============
# plot fork length distribution
# Input needed is a space-separated file with columns bin_lo, bin_hi, fork_length_count
# Such a file will be among the outputs of dnascent_qc
# NOTE: as this script is close to a publication, our focus is on rapidly making the plot and the aesthetics,
#       so some numbers may be hard-coded. If you are not close to publication and are doing some analysis,
#       then there is likely some other script in the repo which does the same thing as this script but more generally
#       and without refined aesthetics.

# usage
# =====
# < some_file.txt Rscript <script_name>.R /path/to/output_file.png

tbl <- read.table(file("stdin"), comment.char = "#", header = TRUE)
tbl$x <- (tbl$bin_lo + tbl$bin_hi)/(2 * 1000)

args <- commandArgs(trailingOnly = TRUE)

r <- ggplot(tbl, aes(x = x, y = fork_length_count)) +
      geom_bar(stat="identity", position=position_dodge(), fill="#003366") +
      scale_x_continuous(expand = c(0.012, 0.012), limits = c(0, 65)) +
      scale_y_continuous(expand = c(0.012, 0.012), limits = c(1, 3800000), trans="log10",
                         breaks=trans_breaks("log10", function(x) 10^x)(c(1, 1e6)),
                         labels=trans_format("log10", math_format(10^.x))) +
      labs(x = "Fork length (kb)", y = "Count") +
      theme_classic(base_size = 50) +
      theme(axis.text = element_text(colour = "black"))

ggsave(args[1], plot = r, dpi = 400, width = 10, height = 9.1)
