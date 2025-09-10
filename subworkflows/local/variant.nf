/*
========================================================================================
    VARIANT CALLING
========================================================================================
*/

include { MEDAKA } from '../../modules/local/medaka/main'

workflow VARIANT_CALLING {
    take:
    trimmed
    masked
    fai

    main:
    ch_versions = Channel.empty()

    masked_fai = masked
        .combine(fai, by: 0)
        .map { meta, reference, fai -> tuple(meta, [reference, fai]) }

    ch_medaka_input = trimmed
        .combine(masked_fai)
        .map { read_meta, reads, ref_meta, reference_bundle ->
            tuple(read_meta, reads, reference_bundle)
        }

    MEDAKA(ch_medaka_input)
    medaka_variants = MEDAKA.out.vcf
    ch_versions = ch_versions.mix(MEDAKA.out.versions)

    emit:
    medaka_variants
    masked_fai
    versions = ch_versions
}
