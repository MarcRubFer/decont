#!/bin/bash


# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
#
# The directory containing the samples is indicated by the first argument ($1).

#Version for 2 replicates following README tip

#cat "$1"/"$3"-12.5dpp.1.1s_sRNA.fastq.gz "$1"/"$3"-12.5dpp.1.2s_sRNA.fastq.gz > "$2"/"$3".fastq.gz

# Version for 2 or more replicates:
mkdir -p "$2"
for repl in $(ls "$1" | grep "$3");
do
	cat "$1"/"$repl" >> "$2"/"$3".fastq.gz
done
