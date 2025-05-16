/*
========================================================================================
    QUALITY CONTROL
========================================================================================
*/

include { NANOCOMP } from '../../modules/nf-core/nanocomp/main'
include { NANOPLOT } from '../../modules/nf-core/nanoplot/main'
include { NANOQC } from '../../modules/local/nanoqc.nf'


workflow QC {
    take:
    reads // channel: [ val(sampleID), [reads] ]


    main:
    ch_versions = Channel.empty()

    NANOCOMP(reads)
    ch_versions = ch_versions.mix(NANOCOMP.out.versions)
    
    NANOPLOT(reads)
    ch_versions = ch_versions.mix(NANOPLOT.out.versions)
    
    NANOQC(reads)
    ch_versions = ch_versions.mix(NANOQC.out.versions) 
   
   emit:
   versions = ch_versions
}