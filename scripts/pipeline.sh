#Packages to install

#seqkit tools
#Citation: W Shen, S Le, Y Li*, F Hu*. SeqKit: a cross-platform and ultrafast toolkit for FASTA/Q file manipulation. PLOS ONE. doi:10.1371/journal.pone.0163962. 
#conda install -c bioconda seqkit

#STAR allignment
#mamba install star

#Cutadapt
#mamba install cutadapt


#Download all the files specified in data/filenames
for url in $(grep "https" $1)
do
    bash scripts/download.sh $url data
done

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes "small nuclear" #TODO-include key to filter as $num

# Index the contaminants file
bash scripts/index.sh res/contaminants.fasta res/contaminants_idx

# Merge the samples into a single file
for sid in $(ls data/*.gz | awk -F"/" '{print $2}' | awk -F"-" '{print $1}' | sort -u)
do
    bash scripts/merge_fastqs.sh data out/merged $sid
done

# TODO: run cutadapt for all merged files
mkdir -p out/trimmed
mkdir -p log/cutadapt

for path in $(find out/merged -path '*.gz')
do
	sample_id=$(basename -s .fastq.gz "$path")
	cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
	-o out/trimmed/"$sample_id".trimmed.fastq.gz \
       	"$path" > log/cutadapt/"$sample_id".log
done

#Run STAR for all trimmed files
for fname in out/trimmed/*.fastq.gz
do
    sid=$(basename -s .trimmed.fastq.gz "$fname")
    echo -e "Align "$sid" to index\n"
    mkdir -p out/star/$sid
    STAR --runThreadN 4 --genomeDir res/contaminants_idx \
         --outReadsUnmapped Fastx \
	 --readFilesIn "$fname" \
         --readFilesCommand gunzip -c --outFileNamePrefix out/star/"$sid"/
done 

# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in
