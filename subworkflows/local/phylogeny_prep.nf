/*
========================================================================================
    PHYLOGENY PREPARATION
========================================================================================
*/
include { BCFTOOLS_SORT } from '../../modules/nf-core/bcftools/sort/main'
include { BCFTOOLS_CONSENSUS } from '../../modules/nf-core/bcftools/consensus/main'
include { COMBINE_CONSENSUS } from '../../modules/local/multi_fasta'

workflow PHYLOGENY_PREP { 
    take:
    medaka_variants
    meta_fasta_only

    main:
    ch_versions = Channel.empty()

    BCFTOOLS_SORT(medaka_variants)
    ch_versions = ch_versions.mix(BCFTOOLS_SORT.out.versions)

    // Get single reference fasta without meta
    reference_fasta = meta_fasta_only.first().map { meta, fasta -> fasta }
    
    // Combine sorted vcf files with fasta reference
    individual_consensus_inputs = BCFTOOLS_SORT.out.vcf
        .join(BCFTOOLS_SORT.out.tbi, by: 0)
        .combine(reference_fasta)
        .map { meta, vcf, tbi, fasta -> 
            [meta, vcf, tbi, fasta]
        }

    // Creates consensus for each sample
    BCFTOOLS_CONSENSUS(individual_consensus_inputs)
    ch_versions = ch_versions.mix(BCFTOOLS_CONSENSUS.out.versions)

    // Collect files for combination
    consensus_files = BCFTOOLS_CONSENSUS.out.fasta
        .map { meta, fasta -> fasta }
        .collect()
        .map { files -> 
            def meta = [id: 'all_samples_consensus']
            [meta, files]
        }

    // Combine into multi-FASTA
    COMBINE_CONSENSUS(consensus_files)

    emit:
    individual_consensus = BCFTOOLS_CONSENSUS.out.fasta
    multi_fasta = COMBINE_CONSENSUS.out.multi_fasta
    versions = ch_versions
}