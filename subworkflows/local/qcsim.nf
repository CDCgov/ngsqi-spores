/*
========================================================================================
    QUALITY CONTROL SIMULATION
========================================================================================
*/

include { NANOCOMP } from '../../modules/nf-core/nanocomp/main'
include { NANOPLOT } from '../../modules/nf-core/nanoplot/main'
include { NANOQC } from '../../modules/local/nanoqc.nf'


workflow QCSIM {
    take:
    simulated_reads

    main:
    ch_versions = Channel.empty()
    ch_multiqc_files  = Channel.empty()

    NANOCOMP(simulated_reads)
    ch_versions = ch_versions.mix(NANOCOMP.out.versions)
    //ch_multiqc_files = ch_multiqc_files.mix(NANOCOMP.out.stats_txt)
    
    NANOPLOT(simulated_reads)
    ch_versions = ch_versions.mix(NANOPLOT.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(NANOPLOT.out.txt)
    
    NANOQC(simulated_reads)
    //ch_versions = ch_versions.mix(NANOQC.out.versions)
    //ch_multiqc_files = ch_multiqc_files.mix(NANOQC.out.stats)  
   
   emit:
   versions = ch_versions
   multiqc = ch_multiqc_files
} 
