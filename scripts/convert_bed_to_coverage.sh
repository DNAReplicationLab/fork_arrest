#!/bin/bash

# goal
# ====
# Given a bed file, calculate the coverage of the genome by the bed file at each window in the genome.
# We require 100% coverage of the window by a bed entry to count it.

# usage
# =====
# bash convert_bed_to_coverage.sh fasta_index_file window_size bed_file > output_file.bedgraph
#     fasta_index_file: index file of the fasta reference genome. usually called <genome>.fa.fai.
#                       This file can be generated by samtools faidx.
#                       The index file is a tab-delimited file without headers.
#                       We'll use only the first two columns which are chromosome name and length in bp.
#     window_size: the size of the window in bp to tile the genome.
#     bed_file: the bed file to calculate the coverage of the genome by. We'll use only the first three columns.
#     (optional) after bed_file, pass "--invert" to require 100% coverage of the bed file interval by the window,
#                rather than the default of 100% coverage of the window by the bed file interval.
#                Such a command looks like this:
#                bash convert_bed_to_coverage.sh fasta_index_file window_size bed_file --invert > output_file.bedgraph

# output
# ======
# The output is to stdout, is space-delimited with no headers and four columns:
# contig, start, end, coverage.
# The fields are self-explanatory.
# Output can be redirected to a file.

# fail if any command fails
set -e

# check that the correct number of arguments were provided
if [ $# -lt 3 ]
then
    >&2 echo "Error: not enough arguments were provided"
    >&2 echo "Goal: Given a bed file, calculate the coverage of the genome by the bed file at each window in the genome."
    >&2 echo "      We require 100% coverage of the window by a bed entry to count it."
    >&2 echo "Usage: bash convert_bed_to_coverage.sh fasta_index_file window_size bed_file > output_file.bedgraph"
    >&2 echo "    fasta_index_file: index file of the fasta reference genome. usually called <genome>.fa.fai."
    >&2 echo "                      This file can be generated by samtools faidx."
    >&2 echo "                      The index file is a tab-delimited file without headers."
    >&2 echo "                      We'll use only the first two columns which are chromosome name and length in bp."
    >&2 echo "    window_size: the size of the window in bp to tile the genome."
    >&2 echo "    bed_file: the bed file to calculate the coverage of the genome by. We'll use only the first three columns."
    >&2 echo "    (optional) after bed_file, pass \"--invert\" to require 100% coverage of the bed file interval by the window,"
    >&2 echo "               rather than the default of 100% coverage of the window by the bed file interval."
    >&2 echo "               Such a command looks like this:"
    >&2 echo "               bash convert_bed_to_coverage.sh fasta_index_file window_size bed_file --invert > output_file.bedgraph"
    >&2 echo "Output: The output is to stdout, is space-delimited with no headers and four columns:"
    >&2 echo "        contig, start, end, coverage."
    exit 1;
fi

# get the arguments
fasta_index_file=$1
window_size=$2
bed_file=$3
invert=${4:-""}

# check that the input files exist
if [ ! -f "$fasta_index_file" ]
then
    >&2 echo "Error: the fasta index file does not exist"
    exit 1;
fi

if [ ! -f "$bed_file" ]
then
    >&2 echo "Error: the bed file does not exist"
    exit 1;
fi

# check that the window size is positive
if [ "$window_size" -le 0 ]
then
    >&2 echo "Error: the window size must be positive"
    exit 1;
fi

# load configuration variables, git labels, and bedtools
source load_package.sh -bedtools
source load_git_repo_labels.sh
source config.sh

# make a temporary file
temp_file=$(mktemp)

# use bedtools make windows to generate a bed file of windows with the given window size
bedtools makewindows -g "$fasta_index_file" -w "$window_size" > "$temp_file"

# print the script information
echo "# from commit ${COMMITSTR:-NA} generated at ${TIMENOW:-NA} by ${config[name]:-NA} <${config[email]:-NA}>";
echo "# script: $0";
echo "# arguments: $*";

# calculate the coverage of the windows by the forks and print four columns: contig, start, end, coverage
# if the invert flag is set, calculate the coverage of the bed file by the windows
if [ "$invert" == "--invert" ]
then
  bash convert_bed_to_coverage_given_windows.sh -i "$temp_file" "$bed_file" "$fasta_index_file"
else
  bash convert_bed_to_coverage_given_windows.sh "$temp_file" "$bed_file" "$fasta_index_file"
fi

# remove the temporary file
rm "$temp_file"