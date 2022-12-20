#This script generate a log file (pipeline.log) which resume some aspects of the alignment.

echo -e "\nPipeline resume - $(date +%F)" > log/pipeline.log
echo -e "----------------------------\n" >> log/pipeline.log

for file in log/cutadapt/*
do 
	sid=$(basename -s .log $file)
	echo -e "From "$sid"\n" >> log/pipeline.log
	echo -e "Cutadapt data:" >> log/pipeline.log
	echo -e "--------------" >> log/pipeline.log
       	grep "Reads with adapters" log/cutadapt/$sid.log >> log/pipeline.log
	grep "Total basepairs processed" log/cutadapt/$sid.log >> log/pipeline.log
	echo >> log/pipeline.log
	echo -e "STAR data:" >> log/pipeline.log
	echo -e "----------" >> log/pipeline.log
	grep "Uniquely mapped reads %" out/star/"$sid"/Log.final.out >> log/pipeline.log
	grep "% of reads mapped to multiple loci" out/star/"$sid"/Log.final.out >> log/pipeline.log
        grep "% of reads unmapped: too many mismatches" out/star/"$sid"/Log.final.out >> log/pipeline.log
	echo >> log/pipeline.log
	echo "-------------------------------------------------------------------------------------------" >> log/pipeline.log
	echo >> log/pipeline.log


done

