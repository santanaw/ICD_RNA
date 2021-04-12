#!/usr/bin/env bash

# Define env variables
itmo="/kingdoms/csb/workspace3/santana/itmo"
DATA_MTX_PBS="$itmo/data/rna_seq/MTX_PBS"
RESULT_EOULSAN="$itmo/results/rna_seq/MTX_PBS/eoulsan"
EOULSAN="/usr/local/src/eoulsan-2.4/eoulsan.sh"


# Extract fastq files for analysis
mkdir -p $DATA_MTX_PBS
cd $DATA_MTX_PBS
sh $itmo/src/extract_MTX_PBS_fastq.v1.0.sh

# Download genome and annotation data
cd $DATA_MTX_PBS
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M25/gencode.vM25.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M25/GRCm38.primary_assembly.genome.fa.gz

# Retain only chromosomes
zcat GRCm38.primary_assembly.genome.fa.gz|head -n 45425663 | gzip -c > GRCm38.genome.fa.gz

# Create EOULSAN output directory
mkdir -p $RESULT_EOULSAN
cd $RESULT_EOULSAN
# Create mock design file
$EOULSAN createdesign --paired-end $DATA_MTX_PBS/*.fastq.gz $DATA_MTX_PBS/GRCm38.genome.fa.gz $DATA_MTX_PBS/gencode.vM25.annotation.gtf.gz


# Double-check the encoding quality of the reads
gunzip -c A2_S2_L001_R1_001_run2.fastq.gz | awk 'NR % 4 == 0' | head -n 1000000 | python $itmo/src/bio-playground/reads-utils/guess-encoding.py

# Run eoulsan
$EOULSAN -conf conf -m 153600 exec workflow-rnaseq.xml design.txt
