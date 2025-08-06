/*
========================================================================================
    PHYLOGENY ESTIMATION
========================================================================================
*/

include { FAMSA_DIST } from '../../modules/nf-core/famsa/align/main.nf'
include { FAMSA_GUIDETREE } from '../../modules/nf-core/famsa/guidetree/main.nf'
include { FASTTREE } from '../../modules/nf-core/fasttree/main.nf'
include { RAPIDNJ } from '../../modules/nf-core/rapidnj/main.nf'

workflow PHYLOGENY_ESTIMATION {

    take:
    multi_fasta_snps
    compress

    main:
    ch_versions = Channel.empty()

    FAMSA_DIST(multi_fasta_snps,compress)
    ch_versions = ch_versions.mix(FAMSA_DIST.out.versions) 

    FAMSA_GUIDETREE(multi_fasta_snps)
    ch_versions = ch_versions.mix(FAMSA_GUIDETREE.out.versions) 
    FASTTREE(multi_fasta_snps)
    ch_versions = ch_versions.mix(FASTTREE.out.versions)

    RAPIDNJ(multi_fasta_snps)
    ch_versions = ch_versions.mix(RAPIDNJ.out.versions)

    emit:
    versions = ch_versions

}


