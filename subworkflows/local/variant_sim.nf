/*
========================================================================================
    VARIANT DETECTION SIMULATION
========================================================================================
*/

include { SAMTOOLS_FAIDX as SAMTOOLS_FAIDX_SIM } from '../../modules/nf-core/samtools/faidx/main'
include { MEDAKA as MEDAKASIM } from '../../modules/nf-core/medaka/main'

workflow VARIANT_SIM {
    take:
    simulated_reads
    ch_first_fasta

    main:
    ch_versions = Channel.empty()
    ch_multiqc_files  = Channel.empty()

    simulated_reads
        .combine(ch_first_fasta)
        .map { meta, reads, reference, clade, var_id, chrom, pos, var_seq, fasta_file ->
            def combined_meta = meta + [
                id: reads.baseName.replaceAll(/(_chopped_chopper)?\.fastq(\.gz)?$/, ''),
                valID: reference,
                clade: clade, 
                var_id: var_id,
                chrom: chrom,
                pos: pos,
                var_seq: var_seq
            ]
            return tuple(combined_meta, reads, fasta_file)
        }
        .set { input_with_meta }

    input_with_meta
        .map { meta, reads, fasta -> tuple(meta, fasta) }
        .set { meta_fasta_only }
    
    input_with_meta
        .map { meta, reads, fasta_file -> 
            def fasta_meta = [id: fasta_file.baseName]
            return tuple(fasta_meta, fasta_file)
        }
        .unique()
        .set { ch_fasta_for_indexing }
    
    SAMTOOLS_FAIDX_SIM(ch_fasta_for_indexing)
    ch_versions = ch_versions.mix(SAMTOOLS_FAIDX_SIM.out.versions)
    
    input_with_meta
        .map { meta, reads, fasta_file -> 
            def fasta_meta = [id: fasta_file.baseName]
            return tuple(fasta_meta, meta, reads, fasta_file)
        }
        .combine(SAMTOOLS_FAIDX_SIM.out.fai, by: 0)
        .map { fasta_meta, meta, reads, fasta_file, fai ->
            return tuple(meta, reads, [fasta_file, fai])
        }
        .set { ch_medaka_input }

    MEDAKASIM(ch_medaka_input)
    medaka_variants_sim = MEDAKASIM.out.vcf
    ch_versions = ch_versions.mix(MEDAKASIM.out.versions)
    
    emit:
    medaka_variants_sim
    versions = ch_versions
}
