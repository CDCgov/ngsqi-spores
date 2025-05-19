# :mushroom: SPORES: Simulation, Phylogeny Estimation, Read Optimization, Resistance Mutation Identification and Evaluation, and Sequence Annotation

### :mushroom: **Pipeline Under Development** :mushroom:

![Pipeline Status](https://img.shields.io/badge/status-in%20development-blue?style=flat&logo=mushroom)

## Introduction

**SPORES: Simulation, Phylogeny Estimation, Read Optimization, Resistance Mutation Identification and Evaluation, and Sequence Annotation** is a bioinformatics pipeline that performs quality control and preprocessing on empirical long sequencing reads, incorporates variants of interest into reference genomes, and generates long read in silico datasets using empirically derived error models and genomes containing variants of interest.

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A522.10.6-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)

The primary objectives of the SPORES workflow entail:

* Generate long read in silico datasets based on genome sequences containing variants of interest and empirical long read error models
* Perform preprocessing and error modeling on empirical long read datasets
* Verify quality of empirical long reads and simulated in silico datasets 

<!-- TODO nf-core:
   Complete this sentence with a 2-3 sentence summary of what types of data the pipeline ingests, a brief overview of the
   major pipeline sections and the types of output it produces. You're giving an overview to someone new
   to nf-core here, in 15-20 seconds. For an example, see https://github.com/nf-core/rnaseq/blob/master/README.md#introduction
-->

<!-- TODO nf-core: Include a figure that guides the user through the major workflow steps. Many nf-core
     workflows use the "tube map" design for that. See https://nf-co.re/docs/contributing/design_guidelines#examples for examples.   -->
<!-- TODO nf-core: Fill in short bullet-pointed list of the default steps in the pipeline -->

This workflow is being built with [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) and utilizes docker and singularity containers to modularize the workflow for optimal maintenance and reproducibility.

# Pipeline Summary
1. Input long read sequencing data (.fastq) and reference genomes (.fna)
2. Perform quality control on sequencing reads using NanoPack tools (`NanoComp`,`NanoPlot`,`NanoQC`)

3. Reference Preparation
4. Simulation
5. Versions Report

## Usage

> [!NOTE]
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline) with `-profile test` before running the workflow on actual data.

> To run the SPORES pipeline minimal test, you will need to add your user-specific credentials for the --ncbi_email and 
> --ncbi_api_key parameters to the profile script located at conf/test.config. 

> Once complete, you can run the minimal test
> with the following command:
> `nextflow run spores.nf -profile test,singularity --outdir <OUTDIR>`

### Set Up:

First, prepare a samplesheet with your input empirical long read data that looks as follows:

`samplesheet.csv`:

```csv
sample,fastq
Sample1, assets/data/B20592.fastq.gz
Sample2, assets/data/B21256.fastq.gz
```

Each row represents a long read fastq file.

You will need to also prepare a samplesheet for reference genomes and variant annotations of interest to be used in simulation. 

`reference_samplesheet.csv`:
```csv
reference,clade,var_id,chrom,pos,var_seq
GCA_016772135.1,1,fks1_hs1,CP060340.1,221636,TACTTGACTTTGTCCTTGAGAGATCCT
GCF_003013715.1,2,fks1_hs1,NC_072812.1,2932580,AGGATCTCTCAAGgacaaagtcaagta
```
Each row corresponds to the following information:

- `reference`: Reference genome accession from NCBI

- `clade`: Clade number associated with Candid auris reference genome

- `var_id`: Label for the given variant of interest

- `chrom`: Chromosome corresponding with variant of interest location

- `pos`: Numerical nucleotide position of variant of interest (use 0-based indexing)

- `var_seq`: Desired variant sequence of interest to be substituted in the given position

For instructions on creating an NCBI account and obtaining an API key, please visit the [National Library of Medicine Support Center](https://support.nlm.nih.gov/kbArticle/?pn=KA-05317).

Now, you can run the pipeline using:

<!-- TODO nf-core: update the following command to include all required parameters for a minimal example -->
### Running SPORES:
Now, you can run the pipeline using:

```bash
nextflow run main.nf \
   --input ont_read_samplesheet.csv \
   --fastas reference_samplesheet.csv \
   --ncbi_email <USER NCBI EMAIL> \
   --ncbi_api_key <API KEY> \
   --outdir <OUTDIR>
```

> [!WARNING]
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_;
> see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

## Credits

SPORES was originally written by the Next Generation Sequencing (NGS) Quality Initiative (QI) In silico Team.

We thank the following people for their extensive assistance in the development of this pipeline:

- CDC Mycotic Diseases Branch (MDB)
- CDC Office of Advanced Molecular Detection (OAMD)
- CDC Office of Laboratory Science and Safety (OLSS)
- CDC Division of Laboratory Systems (DLS)

<!-- TODO nf-core: If applicable, make list of people who have also contributed -->

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use ngsqi/spores for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE).

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
