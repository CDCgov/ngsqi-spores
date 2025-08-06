/*
========================================================================================
    PHYLOGENY ESTIMATION
========================================================================================
*/

include { FASTTREE } from '../../modules/nf-core/fasttree/main.nf'
include { RAPIDNJ } from '../../modules/nf-core/rapidnj/main.nf'

workflow PHYLOGENY_ESTIMATION {

    take:
    multi_fasta_snps
    compress

    main:
    ch_versions = Channel.empty()

    FAMSA

    FASTTREE(multi_fasta_snps)
    ch_versions = ch_versions.mix(FASTTREE.out.versions)

    RAPIDNJ(multi_fasta_snps)
    ch_versions = ch_versions.mix(RAPIDNJ.out.versions)

    emit:
    versions = ch_versions

}
