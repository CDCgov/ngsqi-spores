#!/usr/bin/env nextflow

nextflow.enable.dsl = 2


include { REFDOWNLOAD } from '../../modules/local/ref_download.nf'
include { ALTREFERENCE } from '../../modules/local/alt_reference.nf'
include { READANALYSIS } from '../../modules/local/nanosim_analysis.nf'
include { NANOSIMSIMULATION } from '../../modules/local/nanosim_simulation.nf'


workflow SIMULATION {
    take:
        reference_csv
        ont_reads
        download_script
        altreference_script
        ncbi_email
        ncbi_api_key

    main:
        references = Channel
            .fromPath(reference_csv)
            .splitCsv(header: true)

        reads = Channel
            .fromPath(ont_reads)
            .splitCsv(header: true)

        REFDOWNLOAD(references, download_script, ncbi_email, ncbi_api_key)
        ALTREFERENCE(REFDOWNLOAD.out.genome_data, altreference_script)
   
        ref_ch = ALTREFERENCE.out.alt_genomes
        all_combinations = ref_ch.combine(reads)

        all_combinations_map = all_combinations.map { ref_id, ref_file, alt_ref, row -> 
                def sample_id = row.sample_id
                def fastq = row.fastq
                return [sample_id, fastq, ref_id, ref_file, alt_ref]
        }
        all_combinations_map.view()

        READANALYSIS(all_combinations_map)
        NANOSIMSIMULATION(READANALYSIS.out.model_dir, READANALYSIS.out.model_prefix, ALTREFERENCE.out.alt_genomes)
}
