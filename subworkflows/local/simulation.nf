#!/usr/bin/env nextflow

nextflow.enable.dsl = 2



include { REFDOWNLOAD } from './modules/local/ref_download.nf'
include { ALTREFERENCE } from './modules/local/alt_reference.nf'
include { READANALYSIS } from './modules/local/nanosim_analysis.nf'
include { NANOSIMSIMULATION } from './modules/local/nanosim_simulation.nf'


workflow SIMULATION {
reference_csv="/scicomp/home-pure/xvp4/spores/reference_samplesheet.csv"
ONT_reads="/scicomp/home-pure/xvp4/spores/ont_read_samplesheet.csv"
download_script="/scicomp/home-pure/xvp4/spores/scripts/download_ref.py"
altreference_script="/scicomp/home-pure/xvp4/spores/scripts/edit_reference.py"
ncbi_email="ecstow8@gmail.com"
ncbi_api_key="86d3354165a563e0aa09f4ac42cb7852c608"

references = Channel
    .fromPath(reference_csv)
    .splitCsv(header: true)

reads = Channel
    .fromPath(ONT_reads)
    .splitCsv(header: true)

 main:
    REFDOWNLOAD(references,download_script,ncbi_email,ncbi_api_key)
    ALTREFERENCE(REFDOWNLOAD.out.genome_data,altreference_script)
    READANALYSIS(reads,ALTREFERENCE.out.alt_genomes)
    SIMULATION(READANALYSIS.out.nanosim_model)
}