 /*
========================================================================================
    VARIANT ANNOTATION
========================================================================================
*/
include { SNPEFF_SNPEFF } from '../../modules/nf-core/snpeff/snpeff/main'


workflow VARIANT_ANNOTATION {
    take:
    medaka_variants
    snpeffdb
    snpeffconf

    main:
    ch_versions = Channel.empty()

    SNPEFF_SNPEFF(medaka_variants, snpeffdb, snpeffconf)
    ch_versions = ch_versions.mix(SNPEFF_SNPEFF.out.versions)

    snpeff_annotated = SNPEFF_SNPEFF.out.vcf

    emit:
    snpeff_annotated
    versions = ch_versions
}
