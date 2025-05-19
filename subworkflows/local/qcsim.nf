/*
========================================================================================
    QUALITY CONTROL SIMULATION
========================================================================================
*/

include { NANOCOMP as NANOCOMPSIM } from '../../modules/nf-core/nanocomp/main'
include { NANOPLOT as NANOPLOTSIM } from '../../modules/nf-core/nanoplot/main'
include { NANOQC as NANOQCSIM } from '../../modules/local/nanoqc.nf'


workflow QCSIM {
    take:
    simulated_reads

    main:
    ch_versions = Channel.empty()
    ch_multiqc_files  = Channel.empty()

    NANOCOMPSIM(simulated_reads)
    ch_versions = ch_versions.mix(NANOCOMPSIM.out.versions)
    
    NANOPLOTSIM(simulated_reads)
    ch_versions = ch_versions.mix(NANOPLOTSIM.out.versions)
    
    NANOQCSIM(simulated_reads)
    ch_versions = ch_versions.mix(NANOQCSIM.out.versions)
   
   emit:
   versions = ch_versions
} 
