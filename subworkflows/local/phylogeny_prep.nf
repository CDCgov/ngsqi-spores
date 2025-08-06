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
    clade1_masked
    vcf2phylip_script

    main:
    ch_versions = Channel.empty()
    vcf2phylip_script = Channel.fromPath(params.vcf2phylip_script)

    BCFTOOLS_SORT(medaka_variants)
    ch_versions = ch_versions.mix(BCFTOOLS_SORT.out.versions)

    clade1_masked_single = clade1_masked
        .first()
        .map { meta, files -> 
        [meta, files[0]]
        }

    BCFTOOLS_NORM(BCFTOOLS_SORT.out.vcf,clade1_masked_single)
    ch_versions = ch_versions.mix(BCFTOOLS_NORM.out.versions)

    vcf_csi_with_meta = BCFTOOLS_NORM.out.vcf
        .join(BCFTOOLS_NORM.out.csi, by: 0)
        .toList()
        .map { list_of_items ->
            def all_vcfs = list_of_items.collect { meta, vcf, csi -> vcf }
            def all_csis = list_of_items.collect { meta, vcf, csi -> csi }
            def merge_meta = [id: 'merged_samples'] 
            [merge_meta, all_vcfs, all_csis]
        }

    BCFTOOLS_MERGE(vcf_csi_with_meta,clade1_masked_single)
    ch_versions = ch_versions.mix(BCFTOOLS_MERGE.out.versions)

    VCF2PHYLIP(BCFTOOLS_MERGE.out.vcf_merged, vcf2phylip_script)
    ch_versions = ch_versions.mix(VCF2PHYLIP.out.versions)

    emit:
    multi_vcf = BCFTOOLS_MERGE.out.vcf_merged
    multi_fasta_snps = VCF2PHYLIP.out.fasta
    
    versions = ch_versions
}
