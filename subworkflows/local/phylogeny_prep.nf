/*
========================================================================================
    PHYLOGENY PREPARATION
========================================================================================
*/
include { BCFTOOLS_SORT } from '../../modules/nf-core/bcftools/sort/main'
include { BCFTOOLS_MERGE } from '../../modules/nf-core/bcftools/merge/main'

workflow PHYLOGENY_PREP { 
    take:
    medaka_variants
    meta_fasta_only

    main:
    ch_versions = Channel.empty()

    BCFTOOLS_SORT(medaka_variants)
    ch_versions = ch_versions.mix(BCFTOOLS_SORT.out.versions)

    BCFTOOLS_SORT.out.vcf
        .map { meta, vcf -> tuple('all_samples', vcf) }
        .groupTuple()
        .set { vcfs_grouped }
        
    BCFTOOLS_SORT.out.tbi  
        .map { meta, tbi -> tuple('all_samples', tbi) }
        .groupTuple()
        .set { tbis_grouped }

    // Combine the grouped VCFs and TBIs
    vcfs_grouped
        .join(tbis_grouped)
        .map { key, vcfs, tbis ->
            def merged_meta = [id: 'merged_samples']
            tuple(merged_meta, vcfs, tbis)
        }
        .set { all_vcfs_collected }
        
    // Take just ONE fasta file
    single_fasta = meta_fasta_only.first()
    
    BCFTOOLS_MERGE(all_vcfs_collected, single_fasta)

    ch_versions = ch_versions.mix(BCFTOOLS_MERGE.out.versions)

    multi_fasta = BCFTOOLS_MERGE.out.vcf

    emit:
    multi_fasta
    versions = ch_versions
}