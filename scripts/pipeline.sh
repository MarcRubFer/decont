#!/bin/bash
#Script created by Marcos Rubio Fernández for Advance Linux course in "Master en Bioinformatica aplicada a la Medicina Personalizada y Salud" (2022-23 promotion)

# Check if file from data/urls is already downloaded.
# If not, add url to a temp file (## Bonus 2: Check if the output already exists before running a command.)
for url in $(grep "https" $1)
do
        url_file=$(basename $url)
        if [[ -e data/$url_file ]];
        then
                echo ""$url_file" has been download"
        else
                echo $url >> data/urls_to_download.tmp
		curl -s $url.md5 | cut -d' ' -f1 >> data/online_md5.tmp #(Bonus 3: md5 check. Extraction of md5 hashes without download md5 file)
        fi
done

# Download all files from temp file (## Bonus 1: Replace the loop that downloads the sample data files with a wget one-liner.)

if [[ -s data/urls_to_download.tmp ]];
then
	wget -i data/urls_to_download.tmp -P data
fi

# Bonus 3: extraction of md5 hashes of local files.

for file in data/*.gz;
do
	md5sum $file | cut -d' ' -f1 >> data/local_md5.tmp
done

# Compare md5 hashes (online vs local). Exit programm if not coincidence.
if [[ -e data/online_md5.tmp ]];
then
	if diff data/online_md5.tmp data/local_md5.tmp;
	then
		echo -e "\n-----------------------------------"
		echo -e "\nCheck of md5 hashes OK ... continue"
		echo -e "\n-----------------------------------"
	else
		echo "An error in check of md5 hashes. Interrumping program."
		exit 1
	fi
fi

# Delete url temp file(s).
rm data/*.tmp

# Download the contaminants fasta file, uncompress it, and filter to remove all small nuclear RNAs
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
