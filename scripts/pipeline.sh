#!/bin/bash
#Script created by Marcos Rubio Fernández for Advance Linux course in "Master en Bioinformatica aplicada a la Medicina Personalizada y Salud" (2022-23 promotion)

#Download all the files specified in data/filenames
for url in $(grep "https" $1)
do
    bash scripts/download.sh $url data
done

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes "small nuclear" #TODO-include key to filter as $num

# Index the contaminants file
echo -e "\nSTAR indexing reference genome"
echo -e "-------------------------------"

bash scripts/index.sh res/contaminants.fasta res/contaminants_idx

echo -e "\nDone"
echo -e "-----"

# Merge the samples into a single file
echo -e "\nMerging replicates..."
for sid in $(ls data/*.gz | awk -F"/" '{print $2}' | awk -F"-" '{print $1}' | sort -u)
do
    bash scripts/merge_fastqs.sh data out/merged $sid
done
echo -e "\nDone"
echo -e "------"

# Run cutadapt for all merged files
echo -e "\nFinding and removing adapter sequences..."
mkdir -p out/trimmed
mkdir -p log/cutadapt

for path in $(find out/merged -path '*.gz')
do
	sample_id=$(basename -s .fastq.gz "$path")
	cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
	-o out/trimmed/"$sample_id".trimmed.fastq.gz \
       	"$path" > log/cutadapt/"$sample_id".log
done
echo -e "\nDone"
echo -e "-----"

#Run STAR for all trimmed files
echo -e "\nRunning STAR alignments..."
for fname in out/trimmed/*.fastq.gz
do
    sid=$(basename -s .trimmed.fastq.gz "$fname")
    echo -e "\nAligning "$sid" sequences to index reference.\n"
    mkdir -p out/star/$sid
    STAR --runThreadN 4 --genomeDir res/contaminants_idx \
         --outReadsUnmapped Fastx \
	 --readFilesIn "$fname" \
         --readFilesCommand gunzip -c --outFileNamePrefix out/star/"$sid"/
    echo -e "\nDone"
    echo -e "------"
done 

# Log file containing information from cutadapt and star logs

bash scripts/final_log.sh
cat log/pipeline.log
