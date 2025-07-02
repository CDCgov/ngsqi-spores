  /*
========================================================================================
    VARIANT ANNOTATION SIMULATION
========================================================================================
*/
include { SNPEFF_SNPEFF as SNPEFF_SNPEFF_SIM} from '../../modules/nf-core/snpeff/snpeff/main'


workflow VARIANT_ANN_SIM { 
    take:
    medaka_variants
    snpeff_db_dir
    snpeff_config

    main:
    ch_versions = Channel.empty()
    
    SNPEFF_SNPEFF_SIM(medaka_variants,snpeff_db_dir,snpeff_config)
    ch_versions = ch_versions.mix(SNPEFF_SNPEFF_SIM.out.versions)

    snpeff_annotated = SNPEFF_SNPEFF_SIM.out.vcf

    emit:
    snpeff_annotated
    versions = ch_versions
}

