/*
========================================================================================
    PHYLOGENY PREPARATION
========================================================================================
*/
include { BCFTOOLS_SORT } from '../../modules/nf-core/bcftools/sort/main'
include { BCFTOOLS_NORM } from '../../modules/nf-core/bcftools/norm/main'
include { BCFTOOLS_MERGE } from '../../modules/nf-core/bcftools/merge/main'
include { VCF2PHYLIP } from '../../modules/local/vcf2phylip'

workflow PHYLOGENY_PREP {
    take:
    medaka_variants
    masked

    main:
    ch_versions = Channel.empty()

    BCFTOOLS_SORT(medaka_variants)
    ch_versions = ch_versions.mix(BCFTOOLS_SORT.out.versions)
    vcf_sort = BCFTOOLS_SORT.out.vcf

    BCFTOOLS_NORM(vcf_sort, masked)
    ch_versions = ch_versions.mix(BCFTOOLS_NORM.out.versions)
    vcf = BCFTOOLS_NORM.out.vcf

    vcf_csis = vcf
        .toList()
        .map { records ->
            def vcfs = records.collect { it[1] }
            def csis = records.collect { it[2] }
            def meta = [id: 'merged']
            return tuple(meta, vcfs, csis)
        }

    BCFTOOLS_MERGE(vcf_csis)
    ch_versions = ch_versions.mix(BCFTOOLS_MERGE.out.versions)
    multi_vcf  = BCFTOOLS_MERGE.out.vcf_merged

    VCF2PHYLIP(multi_vcf)
    ch_versions = ch_versions.mix(VCF2PHYLIP.out.versions)
    multi_fasta_snps = VCF2PHYLIP.out.fasta

    emit:
    multi_vcf
    multi_fasta_snps

    versions = ch_versions
}
