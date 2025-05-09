/*
========================================================================================
    SIMULATION
========================================================================================
*/
include { ALTREFERENCE } from '../../modules/local/alt_reference.nf'
include { READANALYSIS } from '../../modules/local/nanosim_analysis.nf'
include { NANOSIMSIMULATION } from '../../modules/local/nanosim_simulation.nf'

workflow SIMULATION {
    take:
        ref_path
        trimmed
        altreference_script

    main:
        ch_versions = Channel.empty()

        // Generate altered reference genomes
        ALTREFERENCE(ref_path, altreference_script)
        alt_genomes_ch = ALTREFERENCE.out.alt_genomes

        ch_version = ch_versions.mix(ALTREFERENCE.out.versions)
        
        // Get first reference
        first_ref = alt_genomes_ch.first()
        
        // Prepare reads
        reads_ch = trimmed.map { meta, fastq -> 
            [meta.id, fastq] 
        }
        
        // Combine reads with first reference
        readanalysis_ch = reads_ch
            .combine(first_ref)
            .map { sample_id, fastq, ref_id, ref_path, alt_ref_path ->
                [ref_id, ref_path, alt_ref_path, sample_id, fastq]
            }
        
        // Run read analysis
        READANALYSIS(readanalysis_ch)
        
        reads_model_prefix=READANALYSIS.out.model_dir

        ch_version = ch_versions.mix(READANALYSIS.out.versions)

        sim_input = reads_model_prefix.combine(alt_genomes_ch)


        // Run simulation
        NANOSIMSIMULATION(sim_input)
        NANOSIMSIMULATION.out.nanosim_output
            .map { sample_id, id, fastq_file -> 
                def meta = [
                    id: sample_id,
                    ref_id: id,
                ]
                return [meta, fastq_file]
            }
            .set { meta_nanosim_output }
     
        simulated_reads = meta_nanosim_output
        ch_versions = ch_versions.mix(NANOSIMSIMULATION.out.versions)

    emit:
        simulated_reads
        versions = ch_versions
}