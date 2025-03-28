#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { REFDOWNLOAD } from './modules/local/ref_download.nf'
include { ALTREFERENCE } from './modules/local/alt_reference.nf'
include { READANALYSIS } from './modules/local/nanosim_analysis.nf'
include { NANOSIMSIMULATION } from './modules/local/nanosim_simulation.nf'

workflow SIMULATION {
    take:
    reference_csv
    ONT_reads
    download_script
    altreference_script
    ncbi_email
    ncbi_api_key

    main:
    references = Channel
        .fromPath(reference_csv)
        .splitCsv(header: true)

    reads = Channel
        .fromPath(ONT_reads)
        .splitCsv(header: true)

    REFDOWNLOAD(references, download_script, ncbi_email, ncbi_api_key)
    ALTREFERENCE(REFDOWNLOAD.out.genome_data, altreference_script)
    READANALYSIS(reads, ALTREFERENCE.out.alt_genomes)
    NANOSIMSIMULATION(READANALYSIS.out.nanosim_model)
}


workflow {

    def reference_csv = "/scicomp/home-pure/xvp4/spores/reference_samplesheet.csv"
    def ONT_reads = "/scicomp/home-pure/xvp4/spores/ont_read_samplesheet.csv"
    def download_script = "/scicomp/home-pure/xvp4/spores/scripts/download_genome.py"
    def altreference_script = "/scicomp/home-pure/xvp4/spores/scripts/edit_reference.py"
    def ncbi_email = "ecstow8@gmail.com" 
    def ncbi_api_key = "86d3354165a563e0aa09f4ac42cb7852c608"


    SIMULATION(
        reference_csv,
        ONT_reads,
        download_script,
        altreference_script,
        ncbi_email,
        ncbi_api_key
    )
}