/*
========================================================================================
    QUALITY CONTROL
========================================================================================
*/

include { NANOCOMP } from '../../modules/nf-core/nanocomp/main'
include { NANOPLOT } from '../../modules/nf-core/nanoplot/main'
include { EXTRACT_READ_COUNT } from '../../modules/local/extract_read_count.nf'
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
    
    // Extract read counts from NanoPlot's NanoStats.txt output
    EXTRACT_READ_COUNT(NANOPLOT.out.txt)
    read_counts = EXTRACT_READ_COUNT.out.read_counts.view()
    
    NANOQC(reads)
    ch_versions = ch_versions.mix(NANOQC.out.versions) 
   
    emit:
    versions = ch_versions
    read_counts

}