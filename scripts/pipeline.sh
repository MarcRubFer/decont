#Packages to install

#seqkit tools
#conda install -c bioconda seqkit

#STAR allignment
#mamba install star

#Cutadapt
#mamba install cutadapt


# Check if file from url is already downloaded. If not, add url to a temp file (## Bonus 2: Check if the output already exists before running a command.)
for url in $(grep "https" $1)
do
        url_file=$(basename $url)
        if [[ -e data/$url_file ]];
        then
                echo ""$url_file" has been download"
        else
                echo $url >> data/urls_to_download.tmp
        fi
done

# Download all files from temp file (## Bonus 1: Replace the loop that downloads the sample data files with a wget one-liner.)

wget -i data/urls_to_download.tmp -P data

# Delete url temp file.
rm data/urls_to_download.tmp

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
