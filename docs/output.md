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
- [PostSim](#postsim) - Performs quality control on simulated dataset
- [Versions Report](#versions-report) - Generates a report containg versions of software used throughout the workflow

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
        * `nanocomp/sample/`
            * `NanoComp_lengths_violin.html`
            * `NanoComp_log_length_violin.html`
            * `NanoComp_N50.html`
            * `NanoComp_number_of_reads.html`
            * `NanoComp_OverlayHistogram.html`
            * `NanoComp_OverlayHistogram_Normalized.html`
            * `NanoComp_OverlayLogHistogram.html`
            * `NanoComp_OverlayLogHistogram_Normalized.html`
            * `NanoComp_quals_violin.html`
            * `NanoComp-report.html`
            * `NanoComp_total_throughput.html`
            * `NanoStats.txt`
        * `nanoplot/sample/`
            * `LengthvsQualityScatterPlot_dot.html`
            * `LengthvsQualityScatterPlot_dot.png`
            * `LengthvsQualityScatterPlot_kde.html`
            * `LengthvsQualityScatterPlot_kde.png`
            * `NanoPlot_20250520_1032.log`
            * `NanoPlot-report.html`
            * `NanoStats.txt`
            * `Non_weightedHistogramReadlength.html`
            * `Non_weightedHistogramReadlength.png`
            * `Non_weightedLogTransformed_HistogramReadlength.html`
            * `Non_weightedLogTransformed_HistogramReadlength.png`
            * `WeightedHistogramReadlength.html`
            * `WeightedHistogramReadlength.png`
            * `WeightedLogTransformed_HistogramReadlength.html`
            * `WeightedLogTransformed_HistogramReadlength.png`
            * `Yield_By_Length.html`
            * `Yield_By_Length.png`
        * `nanoqc/sample/`
            * `nanoQC.html`
            * `NanoQC.log`


[Hostile](https://github.com/bede/hostile) Removes host reads to ensure that only relevant sequence data are retained

Output files:
* `QC/hostile/`
    * `sample.hostile.log`

[FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) generates quality reports on raw and cleaned reads. These reports include key metrics such as per-base sequence quality, GC content, and sequence length distribution. 

Output files:
* `QC/fastqc/`
    * `clean/`
      * `sample.html`
    * `raw/`
      * `sample.html`

## Simulation

**AltReference** Incorporates variant of interest into reference genome sequence using BioPython SeqIO

Output files:
* `variant/`
    * `sample.fna`

[NanoSim](https://github.com/bcgsc/NanoSim) Simulates long reads from input reference genome with variants, using error model based on empirical dataset

Output files:
* `simulated/reads`
    * `sample.fastq.gz`
    * `sample_errorsim.log`
    * `sample_outputsim.log`

## PostSim

[nanopack](https://github.com/wdecoster/nanopack) Generates QC reports and plots

Output files:
* `simulation/qc/`
    * `raw/` or `clean/`
        * `nanocomp/sample/`
            * `NanoComp_lengths_violin.html`
            * `NanoComp_log_length_violin.html`
            * `NanoComp_N50.html`
            * `NanoComp_number_of_reads.html`
            * `NanoComp_OverlayHistogram.html`
            * `NanoComp_OverlayHistogram_Normalized.html`
            * `NanoComp_OverlayLogHistogram.html`
            * `NanoComp_OverlayLogHistogram_Normalized.html`
            * `NanoComp_quals_violin.html`
            * `NanoComp-report.html`
            * `NanoComp_total_throughput.html`
            * `NanoStats.txt`
        * `nanoplot/sample/`
            * `LengthvsQualityScatterPlot_dot.html`
            * `LengthvsQualityScatterPlot_dot.png`
            * `LengthvsQualityScatterPlot_kde.html`
            * `LengthvsQualityScatterPlot_kde.png`
            * `NanoPlot_20250520_1032.log`
            * `NanoPlot-report.html`
            * `NanoStats.txt`
            * `Non_weightedHistogramReadlength.html`
            * `Non_weightedHistogramReadlength.png`
            * `Non_weightedLogTransformed_HistogramReadlength.html`
            * `Non_weightedLogTransformed_HistogramReadlength.png`
            * `WeightedHistogramReadlength.html`
            * `WeightedHistogramReadlength.png`
            * `WeightedLogTransformed_HistogramReadlength.html`
            * `WeightedLogTransformed_HistogramReadlength.png`
            * `Yield_By_Length.html`
            * `Yield_By_Length.png`
        * `nanoqc/sample/`
            * `nanoQC.html`
            * `NanoQC.log`

## Versions Report

Output files:
* `pipeline_info/`
    * `software_versions.yml`