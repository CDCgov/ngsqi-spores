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
    read_counts

    main:
    ch_versions = Channel.empty()

    // Generate altered reference genomes
    ALTREFERENCE(ref_path, altreference_script)
    alt_genomes_ch = ALTREFERENCE.out.alt_genomes
    ch_versions = ch_versions.mix(ALTREFERENCE.out.versions)
        
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
    reads_model_prefix = READANALYSIS.out.model_dir
    ch_versions = ch_versions.mix(READANALYSIS.out.versions)

    // Get read counts by sample ID
    read_counts_by_sample = read_counts.map { sample_id, reads -> 
        [sample_id, reads] 
    }
    
    // First join each model with its sample's read count
    model_with_reads = reads_model_prefix
        .map { sample_id, ref_id, model_dir, model_prefix -> 
            [sample_id, ref_id, model_dir, model_prefix]
        }
        .join(read_counts_by_sample)
    
    // Then combine with all references 
    sim_input_reads = model_with_reads
        .combine(alt_genomes_ch)
        .map { sample_id, ref_id_model, model_dir, model_prefix, reads, alt_ref_id, ref_file, alt_ref ->
            [sample_id, ref_id_model, model_dir, model_prefix, alt_ref_id, ref_file, alt_ref, reads]
        }
        .view()

    // Run simulation
    NANOSIMSIMULATION(sim_input_reads)
    simulated_reads = NANOSIMSIMULATION.out.nanosim_output
        .map { sample_id, ID, fastq_file ->
            def meta = [id: "${sample_id}_${ID}"]
            return [meta, [fastq_file]]
        }
        .groupTuple(by: 0) 
        .map { meta, file_lists ->
            def flattened_files = file_lists.flatten()
            return [meta, flattened_files]
        }
        
    ch_versions = ch_versions.mix(NANOSIMSIMULATION.out.versions)

    emit:
    simulated_reads
    versions = ch_versions
}