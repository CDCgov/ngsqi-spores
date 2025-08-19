/*
========================================================================================
    VARIANT CALLING
========================================================================================
*/

include { MEDAKA } from '../../modules/local/medaka/main'

workflow VARIANT_CALLING {
    take:
    trimmed         // Channel: tuple val(meta), path("*_chopper.fastq.gz")
    masked          // Channel: tuple val(meta), path("*.fa") — masked FASTA
    fai             // Channel: tuple val(meta), path("*.fai") — index for masked FASTA

    main:
    ch_versions = Channel.empty()

    //Match masked FASTA and .fai index
    masked_fai = masked
        .combine(fai, by: 0)
        .map { meta, reference, fai -> tuple(meta, [reference, fai]) }

    //Pair each trimmed read with the reference+index
    ch_medaka_input = trimmed
        .combine(masked_fai)
        .map { read_meta, reads, ref_meta, reference_bundle ->
            tuple(read_meta, reads, reference_bundle)
        }

    //Run Medaka
    MEDAKA(ch_medaka_input)
    medaka_variants = MEDAKA.out.vcf
    ch_versions = ch_versions.mix(MEDAKA.out.versions)

    emit:
    medaka_variants
    masked_fai
    versions = ch_versions
}
