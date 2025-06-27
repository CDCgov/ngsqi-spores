/*
========================================================================================
    SIMULATION
========================================================================================
*/
include { ALTREFERENCE } from '../../modules/local/alt_reference.nf'
include { READANALYSIS } from '../../modules/local/nanosim_analysis.nf'
include { SEQTK_SAMPLE } from '../../modules/nf-core/seqtk/sample/main'
include { SHORTENHEADERS } from '../../modules/local/shorten_headers.nf'
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

    // Prepare reads with meta map for SEQTK_SAMPLE
    reads_with_meta = trimmed.map { meta, fastq ->
        [meta, fastq]
    }

    // Use nf-core SEQTK_SAMPLE module
    reads_with_sample_size = reads_with_meta.map { meta, fastq ->
        [meta, fastq, 0.1]  // Sample 10% of reads
    }
    SEQTK_SAMPLE(reads_with_sample_size)

    // Convert back to original format for downstream processes
    reads_ch = SEQTK_SAMPLE.out.reads.map { meta, fastq ->
        [meta.id, fastq]
    }

    // Combine reads with first reference (keeping original structure)
    readnanosim_ch = reads_ch
        .combine(first_ref)
        .map { sample_id, fastq, ref_id, ref_path, clade, var_id, alt_ref_path ->
            [ref_id, ref_path, alt_ref_path, sample_id, fastq, clade, var_id]
    }

    //Shorten fastq headers
    SHORTENHEADERS(readnanosim_ch)

    // Need to add alt_ref back to the channel for READANALYSIS
    readanalysis_input = SHORTENHEADERS.out.shortened_fastq
        .join(readnanosim_ch.map { ref_id, ref_path, alt_ref_path, sample_id, fastq, clade, var_id ->
            [sample_id, alt_ref_path]
        })
        .map { sample_id, ref_id, shortened_fastq, clade, var_id, alt_ref_path ->
            [sample_id, ref_id, shortened_fastq, clade, var_id, alt_ref_path]
        }

    // Run read analysis
    READANALYSIS(readanalysis_input)
    reads_model_prefix = READANALYSIS.out.model_dir
    ch_versions = ch_versions.mix(READANALYSIS.out.versions)

    // Get read counts by sample ID
    read_counts_by_sample = read_counts.map { sample_id, reads ->
        [sample_id, reads]
    }

    // First join each model with its sample's read count
    model_with_reads = reads_model_prefix
        .map { sample_id, ref_id, model_dir, model_prefix, clade, var_id ->
            [sample_id, ref_id, model_dir, model_prefix, clade, var_id]
        }
        .join(read_counts_by_sample)

    // Then combine with all references
    sim_input_reads = model_with_reads
        .combine(alt_genomes_ch)
        .map { sample_id, ref_id_model, model_dir, model_prefix, clade_model, var_id_model, reads,
            alt_ref_id, ref_file, clade_ref, var_id_ref, alt_ref ->
            [sample_id, ref_id_model, model_dir, model_prefix, alt_ref_id, ref_file, alt_ref, reads, clade_ref, var_id_ref]
        }

    // Run simulation
    NANOSIMSIMULATION(sim_input_reads)
    simulated_reads = NANOSIMSIMULATION.out.nanosim_output
        .map { sample_id, ID, fastq_file, clade, var_id ->
            def meta = [id: "${sample_id}_${ID}_${clade}_${var_id}"]
            return [meta, fastq_file]
        }

    ch_versions = ch_versions.mix(NANOSIMSIMULATION.out.versions)

    emit:
    simulated_reads
    versions = ch_versions
}

