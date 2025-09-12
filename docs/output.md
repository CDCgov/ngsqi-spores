# spores: Output

## Introduction

This document describes the output produced by the pipeline

The directories listed below will be created in the results directory after the pipeline has finished. All paths are relative to the top-level results directory.

<!-- TODO nf-core: Write this documentation describing your workflow's output -->

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/) and processes data using the following steps:

- [Input Validation](#input-validation) - Verifies structure and contents of the input samplesheets
- [Reference Preparation](#reference-preparation) - Prepares reference for alignment and variant calling
- [Preprocessing](#preprocessing) - Filters reads based on quality and length
- [Quality Control](#quality-control) - Performs quality control on long read data before and after preprocessing
- [Simulation](#simulation) - Simulates long read datasets that contain genetic variants of interest
- [Variant Detection and Annotation](#variant-detection-and-annotation) - Calls and annotates variants in empirical and simulated datasets
- [Phylogeny Estimation](#phylogeny-estimation) - Generates phylogenetic trees and distance matrices for empirical and simulated datasets
- [PostSim](#postsim) - Performs quality control on simulated dataset
- [Versions Report](#versions-report) - Generates a report containg versions of software used throughout the workflow

**Output Nomenclature**

Output names are formatted as in the following example:
```
B19617_GCA_016772135.1_1_fks1_hs1
```
| Column    | Description                                                                                                                                                                            |
| --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `B19617`  | ONT dataset |
| `GCA_016772135.1` | NCBI genome accession                                                             |
| `1` | Clade number                                                             |
| `fks1_hs1` | Variant ID                                                             |

## Input Validation

Output files: no outputs generated

## Reference Preparation

[nucmer](https://github.com/mummer4/mummer) Identifies genomic repeats
[bedtools](https://github.com/arq5x/bedtools2) Masks repeat sequencing

Output files:
* `reference/masked`
    * `sample.bed`
    * `sample.coords`
    * `sample.fa`

[bwa](https://github.com/lh3/bwa) Generates genome reference

Output files:
* `reference/bwa`
    * `sample.amb`
    * `sample.ann`
    * `sample.bwt`
    * `sample.bed`
    * `sample.coords`

[picard](https://github.com/broadinstitute/picard) Generates genome dictionary file

Output files:
* `reference/dict`
    * `sample.dict`

[SAMtools](https://github.com/samtools/samtools) Creates fasta file index

Output files:
* `reference/fai`
    * `sample.fa.fai`

## Preprocessing

[chopper](https://github.com/wdecoster/chopper/) Filters long read sequencing files

Output files: no outputs generated

## Quality Control

[nanopack](https://github.com/wdecoster/nanopack) Generates QC reports and plots

Output files:
* `qc/`
    * `raw/` or `clean/`
        * `nanocomp/all/reports`
            * `allNanoComp_lengths_violin.html`
            * `allNanoComp_log_length_violin.html`
            * `allNanoComp_N50.html`
            * `allNanoComp_number_of_reads.html`
            * `allNanoComp_OverlayHistogram.html`
            * `allNanoComp_OverlayHistogram_Normalized.html`
            * `allNanoComp_OverlayLogHistogram.html`
            * `allNanoComp_OverlayLogHistogram_Normalized.html`
            * `allNanoComp_quals_violin.html`
            * `allNanoComp-report.html`
            * `allNanoComp_total_throughput.html`
        * `nanocomp/all/logs`
            * `allNanoStats.txt`
        * `nanoplot/sample/figures`
            * `LengthvsQualityScatterPlot_dot.png`
            * `LengthvsQualityScatterPlot_kde.png`
            * `Non_weightedHistogramReadlength.png`
            * `Non_weightedLogTransformed_HistogramReadlength.png`
            * `WeightedLogTransformed_HistogramReadlength.png`
            * `WeightedHistogramReadlength.png`
            * `Yield_By_Length.png`
        * `nanoplot/sample/reports`
            * `LengthvsQualityScatterPlot_dot.html`
            * `LengthvsQualityScatterPlot_kde.html`
            * `NanoPlot-report.html`
            * `Non_weightedHistogramReadlength.html`
            * `Non_weightedLogTransformed_HistogramReadlength.html`
            * `WeightedHistogramReadlength.html`
            * `WeightedLogTransformed_HistogramReadlength.html`
            * `Yield_By_Length.html`
        * `nanoplot/sample/logs`
            * `NanoStats.txt`
        * `nanoqc/sample/logs`
            * `NanoQC.log`
        * `nanoqc/sample/reports`
            * `nanoQC.html`

## Simulation

**AltReference** Incorporates variant of interest into reference genome sequence using BioPython SeqIO

Output files:
* `simulation/alt_reference/`
    * `sample.fna`

[NanoSim](https://github.com/bcgsc/NanoSim) Simulates long reads from input reference genome with variants, using error model based on empirical dataset

Output files:
* `simulation/nanosim/`
    * `logs/sample/`
        * `sample_errorsim.log`
        * `sample_outputsim.log`
    * `reads/sample/`
        * `sample.fastq.gz`

## Variant Detection and Annotation

[medaka](https://github.com/nanoporetech/medaka) Calls variants in nanopore sequencing data

Output files:
* `variant/medaka/sample`
    * `medaka.annotated.vcf`

[SNPEff](https://pcingola.github.io/SnpEff/) Annotates genetic variants and predict functional effects

Output files:
* `variant/annotated`
    * `sample.ann.vcf`

[vcf2phylip](https://github.com/edgardomortiz/vcf2phylip) Converts VCF formatted files to FASTA alignments

Output files:
* `variant/multifasta`
    * `merged.min1.fasta`

## Phylogeny Estimation

[FAMSA](https://github.com/refresh-bio/FAMSA) Generates phylogenetic trees and distance matrices using a progressive algorithm

Output files:
* `phylogeny/famsa_dist/`
    * `merged.csv`
* `phylogeny/famsa_guidetree/`
    * `merged_sl.dnd`
    * `merged_upgma.dnd`

[FastTree](https://github.com/morgannprice/fasttree) Generates approximately-maximum-likelihood phylogenetic trees

Output files:
* `phylogeny/fasttree`
    * `fasttree_phylogeny.tre`

[RapidNJ](https://github.com/johnlees/rapidnj) Uses an efficient neighbour-joining algorithm to calculate phylogenetic relationships

Output files:
* `phylogeny/rapidnj`
    * `alignment.sth`
    * `rapidnj_phylogeny.tre`

## PostSim

## Quality Control

[nanopack](https://github.com/wdecoster/nanopack) Generates QC reports and plots

* `simulation/qc/`
    * `raw/` or `clean/`
        * `nanocomp/all/reports`
            * `allNanoComp_lengths_violin.html`
            * `allNanoComp_log_length_violin.html`
            * `allNanoComp_N50.html`
            * `allNanoComp_number_of_reads.html`
            * `allNanoComp_OverlayHistogram.html`
            * `allNanoComp_OverlayHistogram_Normalized.html`
            * `allNanoComp_OverlayLogHistogram.html`
            * `allNanoComp_OverlayLogHistogram_Normalized.html`
            * `allNanoComp_quals_violin.html`
            * `allNanoComp-report.html`
            * `allNanoComp_total_throughput.html`
        * `nanocomp/all/logs`
            * `allNanoStats.txt`
        * `nanoplot/sample/figures`
            * `LengthvsQualityScatterPlot_dot.png`
            * `LengthvsQualityScatterPlot_kde.png`
            * `Non_weightedHistogramReadlength.png`
            * `Non_weightedLogTransformed_HistogramReadlength.png`
            * `WeightedLogTransformed_HistogramReadlength.png`
            * `WeightedHistogramReadlength.png`
            * `Yield_By_Length.png`
        * `nanoplot/sample/reports`
            * `LengthvsQualityScatterPlot_dot.html`
            * `LengthvsQualityScatterPlot_kde.html`
            * `NanoPlot-report.html`
            * `Non_weightedHistogramReadlength.html`
            * `Non_weightedLogTransformed_HistogramReadlength.html`
            * `WeightedHistogramReadlength.html`
            * `WeightedLogTransformed_HistogramReadlength.html`
            * `Yield_By_Length.html`
        * `nanoplot/sample/logs`
            * `NanoStats.txt`
        * `nanoqc/sample/logs`
            * `NanoQC.log`
        * `nanoqc/sample/reports`
            * `nanoQC.html`

## Variant Detection and Annotation

[medaka](https://github.com/nanoporetech/medaka) Calls variants in nanopore sequencing data

Output files:
* `simulation/variant/medaka/sample`
    * `medaka.annotated.vcf`

[SNPEff](https://pcingola.github.io/SnpEff/) Annotates genetic variants and predict functional effects

Output files:
* `simulation/variant/annotated`
    * `sample.ann.vcf`

[vcf2phylip](https://github.com/edgardomortiz/vcf2phylip) Converts VCF formatted files to FASTA alignments

Output files:
* `simulation/variant/multifasta`
    * `merged.min1.fasta`

## Phylogeny Estimation

[FAMSA](https://github.com/refresh-bio/FAMSA) Generates phylogenetic trees and distance matrices using a progressive algorithm

Output files:
* `simulation/phylogeny/famsa_dist/`
    * `merged.csv`
* `simulation/phylogeny/famsa_guidetree/`
    * `merged_sl.dnd`
    * `merged_upgma.dnd`

[FastTree](https://github.com/morgannprice/fasttree) Generates approximately-maximum-likelihood phylogenetic trees

Output files:
* `simulation/phylogeny/fasttree`
    * `fasttree_phylogeny.tre`

[RapidNJ](https://github.com/johnlees/rapidnj) Uses an efficient neighbour-joining algorithm to calculate phylogenetic relationships

Output files:
* `simulation/phylogeny/rapidnj`
    * `alignment.sth`
    * `rapidnj_phylogeny.tre`

## Versions Report

Output files:
* `pipeline_info/`
    * `execution_report_2025-09-04_19-25-01.html`
    * `execution_timeline_2025-09-04_19-25-01.html`
    * `execution_trace_2025-09-04_19-25-01.txt`
    * `fastas.valid.csv`
    * `params_2025-09-05_03-32-47.json`
    * `pipeline_dag_2025-09-04_19-25-01.html`
    * `samplesheet.valid.csv`
    * `software_versions.yml`