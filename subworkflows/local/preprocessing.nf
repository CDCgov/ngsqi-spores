/*
========================================================================================
    PREPROCESSING
========================================================================================
*/

include { CHOPPER } from '../../modules/nf-core/chopper/main'

workflow REF_PREP {
    take:
    reads


    main:
    ch_versions = Channel.empty()
    ch_multiqc_files  = Channel.empty()

    CHOPPER(reads)
    ch_versions = ch_versions.mix(CHOPPER.out.versions)


   emit:
   versions = ch_versions
}