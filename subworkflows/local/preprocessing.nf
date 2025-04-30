/*
========================================================================================
    PREPROCESSING
========================================================================================
*/

include { CHOPPER } from '../../modules/nf-core/chopper/main'

workflow PREPROCESSING {
    take:
    reads


    main:
    ch_versions = Channel.empty()

    CHOPPER(reads)
    ch_versions = ch_versions.mix(CHOPPER.out.versions)


   emit:
   versions = ch_versions
}