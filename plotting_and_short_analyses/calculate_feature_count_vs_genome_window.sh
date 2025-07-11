#!/bin/bash

# goal
# =====
# Given many feature files, calculate the number of features at each window in the genome
# We require 100% coverage of the window by the feature to count it.

# usage
# =====
# bash calculate_feature_count_vs_genome_window.sh fasta_index_file window_size feature_file_1 feature_file_2 ... \
#     > output_file.bedgraph
# NOTE: \ means that the command continues on the next line
# NOTE: ... means that you can provide as many feature files as you want
# fasta_index_file: index file of the fasta reference genome.
#                   E.g. if the reference genome is sacCer3.fa, the index file is usually called sacCer3.fa.fai.
#                   This file can be generated by samtools faidx.
#                   The index file is a tab-delimited file without headers.
#                   We'll use only the first two columns which are chromosome name and length in bp.
# window_size: the size of the window in bp to tile the genome.
# feature_file_1, feature_file_2, ...: the feature files in the format output by forkSense
#                                      (i.e. the left fork file, the right fork file, origin file, etc.)
# output_file.bedgraph: the output file in bedgraph format

# output
# ======
# Output is to stdout, is space-delimited with no headers and four columns:
# contig, start, end, coverage.
# The fields are self-explanatory.
# Output can be redirected to a file.

# fail if any command fails
set -e

# check that the correct number of arguments were provided
if [ $# -lt 3 ]
then
    >&2 echo "Error: not enough arguments were provided"
    >&2 echo "Goal: Given many feature files, calculate the number of features at each window in the genome."
    >&2 echo "      We require 100% coverage of the window by the feature to count it."
    >&2 echo "Usage: bash calculate_feature_count_vs_genome_window.sh fasta_index_file window_size\ "
    >&2 echo "            feature_file_1 feature_file_2 ... > output_file.bedgraph"
    >&2 echo "    NOTE: \ means that the command continues on the next line"
    >&2 echo "    NOTE: ... means that you can provide as many feature files as you want"
    >&2 echo "    fasta_index_file: index file of the fasta reference genome."
    >&2 echo "                  E.g. if the reference genome is sacCer3.fa, the index file is usually called sacCer3.fa.fai."
    >&2 echo "                  This file can be generated by samtools faidx."
    >&2 echo "                  The index file is a tab-delimited file without headers."
    >&2 echo "                  We'll use only the first two columns which are chromosome name and length in bp."
    >&2 echo "    window_size: the size of the window in bp to tile the genome."
    >&2 echo "    feature_file_1, feature_file_2, ...: the feature files in the format output by forkSense"
    exit 1
fi

# set variables
fasta_index_file=$1
window_size=$2
# arguments 3, 4, ... are the feature files
feature_files=("${@:3}")

# check that the fasta index file exists
if [ ! -f "$fasta_index_file" ]
then
    >&2 echo "Error: fasta index file $fasta_index_file does not exist"
    exit 1
fi

# check that the window size is a positive integer
if ! [ "$window_size" -gt 0 ]
then
    >&2 echo "Error: window size $window_size is not a positive integer"
    exit 1
fi

# check that the feature files exist
for feature_file in "${feature_files[@]}"
do
    if [ ! -f "$feature_file" ]
    then
        >&2 echo "Error: feature file $feature_file does not exist"
        exit 1
    fi
done

# load bedtools, git labels, and information about the person running the script
pwd=$(pwd)
cd ..;
source load_package.sh -bedtools
source load_git_repo_labels.sh
source config.sh
cd "$pwd"

# make a temporary file
fork_file_temp=$(mktemp)

# print only the first three columns of the feature files to the temporary file
for feature_file in "${feature_files[@]}"
do
    awk 'BEGIN{OFS="\t"}{print $1, $2, $3}' "$feature_file" >> "$fork_file_temp"
done

# print the script information
echo "# from commit ${COMMITSTR:-NA} generated at ${TIMENOW:-NA} by ${config[name]:-NA}"
echo "# script: $0";
echo "# arguments: $*";

# convert bed file to coverage
cd ..;
bash convert_bed_to_coverage.sh "$fasta_index_file" "$window_size" "$fork_file_temp";

# remove the temporary files
rm "$fork_file_temp"