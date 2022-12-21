#!/bin/bash
#Script created by Marcos Rubio Fernández for Advance Linux course in "Master en Bioinformatica aplicada a la Medicina Personalizada y Salud" (2022-23 promotion)

# This script should index the genome file specified in the first argument ($1),
# creating the index in a directory specified by the second argument ($2).

# The STAR command is provided for you. You should replace the parts surrounded
# by "<>" and uncomment it.

STAR --runThreadN 4 --runMode genomeGenerate \
--genomeDir "$2" \
--genomeFastaFiles "$1" \
--genomeSAindexNbases 9
