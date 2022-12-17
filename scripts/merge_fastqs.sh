# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
#
# The directory containing the samples is indicated by the first argument ($1).

# Merge the samples into a single file
#for sid in $(<list_of_sample_ids>) #TODO
#do
#    bash scripts/merge_fastqs.sh data out/merged $sid
#done

#script del pipeline.sh
#for sid in $(ls data/*.gz | awk -F"/" '{print $2}' | awk -F"-" '{print $1}' | sort -u) # versión 1 corta en C57BL_6nj
#for sid in $(find data -name '*.gz' -exec basename {} \; | awk -F"-" '{print $1}' | sort -u) #version 2 corta en C57BL_6NJ
#do
#    bash scripts/merge_fastqs.sh data out/merged $sid
#done

#Según el README

#cat "$1"/"$3"-12.5dpp.1.1s_sRNA.fastq.gz "$1"/"$3"-12.5dpp.1.2s_sRNA.fastq.gz > "$2"/"$3".fastq.gz

for repl in $(ls "$1" | grep "$3");
do
	echo "loop"
	cat "$1"/"$repl" >> "$2"/"$3".fastq.gz
done
