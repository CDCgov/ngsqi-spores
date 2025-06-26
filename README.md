# :mushroom: SPORES: Simulation, Phylogeny Estimation, Read Optimization, Resistance Mutation Identification and Evaluation, and Sequence Annotation

### :mushroom: **Pipeline Under Development** :mushroom:

![Pipeline Status](https://img.shields.io/badge/status-in%20development-blue?style=flat&logo=mushroom)

## Introduction

**SPORES: Simulation, Phylogeny Estimation, Read Optimization, Resistance Mutation Identification and Evaluation, and Sequence Annotation** is a bioinformatics pipeline that performs quality control and preprocessing on empirical, long sequencing reads, incorporates variants of interest into reference genomes, and generates long-read _in silico_ datasets using empirically derived error models and genomes containing variants of interest.

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A522.10.6-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)

The primary objectives of the SPORES workflow entail:

* Generate long-read _in silico_ datasets based on genome sequences containing variants of interest and empirical long-read error models
* Perform preprocessing and error modeling on empirical long-read datasets
* Verify quality of empirical long reads and simulated _in silico_ datasets 

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
1. Input long-read sequencing data (.fastq) and reference genomes (.fna)
2. Perform quality control on sequencing reads using NanoPack tools (`NanoComp`,`NanoPlot`,`NanoQC`)
3. Preprocess empirical long-read data by filtering reads based on quality and length (`chopper`)
4. Prepare reference genomes for BWA alignment and variant calling (`NUCmer`,`bedtools`,`BWA`,`SAMtools`)
5. Modify reference genomes to contain variants of interest and simulate long sequencing reads (`SeqIO`,`NanoSim`)
6. Generate versions report

## Getting Started

Before running the pipeline, ensure Git LFS is installed and set up.

### 1. Install Git LFS
Run the following command to install Git LFS:
```sh
git lfs install
```
### 2. Clone the repository
Use:
```sh
git clone <repo-url>
```
### 3. Pull LFS tracked files
After cloning, run:
```sh
git lfs pull
```

## Usage

>**Note**
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline) with `-profile test` before running the workflow on actual data.

> To run the SPORES pipeline minimal test, you will need to add your user-specific credentials for the --ncbi_email and 
> --ncbi_api_key parameters to the profile script located at conf/test.config. 

> Once complete, you can run the minimal test
> with the following command:
> `nextflow run spores.nf -profile test,singularity --outdir <OUTDIR>`

### Set Up:

First, prepare a samplesheet with your input, empirical long-read data so that it resembles the following:

`samplesheet.csv`:

```csv
sample,fastq
Sample1, assets/data/B20592.fastq.gz
Sample2, assets/data/B21256.fastq.gz
```

Each row represents a long-read fastq file.

You will also need to prepare a samplesheet for reference genomes and variant annotations of interest to be used in simulation. 

`reference_samplesheet.csv`:
```csv
reference,clade,var_id,chrom,pos,var_seq
GCA_016772135.1,1,fks1_hs1,CP060340.1,221636,TACTTGACTTTGTCCTTGAGAGATCCT
GCF_003013715.1,2,fks1_hs1,NC_072812.1,2932580,AGGATCTCTCAAGgacaaagtcaagta
```
Each row corresponds to the following information:

- `reference`: Reference genome accession from NCBI

- `clade`: Clade number associated with _Candida auris_ reference genome

- `var_id`: Label for the given variant of interest

- `chrom`: Chromosome corresponding to variant of interest location

- `pos`: Numerical nucleotide position of variant of interest (use 0-based indexing)

- `var_seq`: Desired variant sequence of interest to be substituted in the given position

For instructions on creating an NCBI account and obtaining an API key, please visit the [National Library of Medicine Support Center](https://support.nlm.nih.gov/kbArticle/?pn=KA-05317).


<!-- TODO nf-core: update the following command to include all required parameters for a minimal example -->
### Running SPORES:
Now, you can run the pipeline using:

```bash
nextflow run main.nf \
   --input ont_read_samplesheet.csv \
   --fastas reference_samplesheet.csv \
   --ncbi_email <USER NCBI EMAIL> \
   --ncbi_api_key <API KEY> \
   --outdir <OUTDIR> \
   -profile singularity,cdc
```

>**Warning**
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files, including those provided by the `-c` Nextflow option, can be used to provide any configuration _**except for parameters**_;
> see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

## Credits

SPORES was originally written by the Next Generation Sequencing (NGS) Quality Initiative (QI) _In Silico_ Team.

We thank the following groups for their extensive assistance in the development of this pipeline:

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
# CDCgov GitHub Organization Open Source Project Template

**Template for clearance: This project serves as a template to aid projects in starting up and moving through clearance procedures. To start, create a new repository and implement the required [open practices](open_practices.md), train on and agree to adhere to the organization's [rules of behavior](rules_of_behavior.md), and [send a request through the create repo form](https://forms.office.com/Pages/ResponsePage.aspx?id=aQjnnNtg_USr6NJ2cHf8j44WSiOI6uNOvdWse4I-C2NUNk43NzMwODJTRzA4NFpCUk1RRU83RTFNVi4u) using language from this template as a Guide.**

**General disclaimer** This repository was created for use by CDC programs to collaborate on public health related projects in support of the [CDC mission](https://www.cdc.gov/about/cdc/#cdc_about_cio_mission-our-mission).  GitHub is not hosted by the CDC, but is a third party website used by CDC and its partners to share information and collaborate on software. CDC use of GitHub does not imply an endorsement of any one particular service, product, or enterprise. 

## Access Request, Repo Creation Request

* [CDC GitHub Open Project Request Form](https://forms.office.com/Pages/ResponsePage.aspx?id=aQjnnNtg_USr6NJ2cHf8j44WSiOI6uNOvdWse4I-C2NUNk43NzMwODJTRzA4NFpCUk1RRU83RTFNVi4u) _[Requires a CDC Office365 login, if you do not have a CDC Office365 please ask a friend who does to submit the request on your behalf. If you're looking for access to the CDCEnt private organization, please use the [GitHub Enterprise Cloud Access Request form](https://forms.office.com/Pages/ResponsePage.aspx?id=aQjnnNtg_USr6NJ2cHf8j44WSiOI6uNOvdWse4I-C2NUQjVJVDlKS1c0SlhQSUxLNVBaOEZCNUczVS4u).]_

## Related documents

* [Open Practices](open_practices.md)
* [Rules of Behavior](rules_of_behavior.md)
* [Thanks and Acknowledgements](thanks.md)
* [Disclaimer](DISCLAIMER.md)
* [Contribution Notice](CONTRIBUTING.md)
* [Code of Conduct](code-of-conduct.md)

## Overview

Describe the purpose of your project. Add additional sections as necessary to help collaborators and potential collaborators understand and use your project.
  
## Public Domain Standard Notice
This repository constitutes a work of the United States Government and is not
subject to domestic copyright protection under 17 USC § 105. This repository is in
the public domain within the United States, and copyright and related rights in
the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
All contributions to this repository will be released under the CC0 dedication. By
submitting a pull request you are agreeing to comply with this waiver of
copyright interest.

## License Standard Notice
The repository utilizes code licensed under the terms of the Apache Software
License and therefore is licensed under ASL v2 or later.

This source code in this repository is free: you can redistribute it and/or modify it under
the terms of the Apache Software License version 2, or (at your option) any
later version.

This source code in this repository is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the Apache Software License for more details.

You should have received a copy of the Apache Software License along with this
program. If not, see http://www.apache.org/licenses/LICENSE-2.0.html

The source code forked from other open source projects will inherit its license.

## Privacy Standard Notice
This repository contains only non-sensitive, publicly available data and
information. All material and community participation is covered by the
[Disclaimer](DISCLAIMER.md)
and [Code of Conduct](code-of-conduct.md).
For more information about CDC's privacy policy, please visit [http://www.cdc.gov/other/privacy.html](https://www.cdc.gov/other/privacy.html).

## Contributing Standard Notice
Anyone is encouraged to contribute to the repository by [forking](https://help.github.com/articles/fork-a-repo)
and submitting a pull request. (If you are new to GitHub, you might start with a
[basic tutorial](https://help.github.com/articles/set-up-git).) By contributing
to this project, you grant a world-wide, royalty-free, perpetual, irrevocable,
non-exclusive, transferable license to all users under the terms of the
[Apache Software License v2](http://www.apache.org/licenses/LICENSE-2.0.html) or
later.

All comments, messages, pull requests, and other submissions received through
CDC including this GitHub page may be subject to applicable federal law, including but not limited to the Federal Records Act, and may be archived. Learn more at [http://www.cdc.gov/other/privacy.html](http://www.cdc.gov/other/privacy.html).

## Records Management Standard Notice
This repository is not a source of government records, but is a copy to increase
collaboration and collaborative potential. All government records will be
published through the [CDC web site](http://www.cdc.gov).

## Additional Standard Notices
Please refer to [CDC's Template Repository](https://github.com/CDCgov/template) for more information about [contributing to this repository](https://github.com/CDCgov/template/blob/main/CONTRIBUTING.md), [public domain notices and disclaimers](https://github.com/CDCgov/template/blob/main/DISCLAIMER.md), and [code of conduct](https://github.com/CDCgov/template/blob/main/code-of-conduct.md).
