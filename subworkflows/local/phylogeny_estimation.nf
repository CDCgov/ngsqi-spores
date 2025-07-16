/*
========================================================================================
    PHYLOGENY ESTIMATION
========================================================================================
*/



include { MAFFT_ALIGN } from '../../modules/nf-core/mafft/align/main.nf'
include { FASTTREE } from '../../modules/nf-core/fasttree/main.nf'
include { RAPIDNJ } from '../../modules/nf-core/rapidnj/main.nf'


workflow PHYLOGENY_ESTIMATION {

    take:
    multi_fasta
    compress

    main:
    ch_versions = Channel.empty()

    MAFFT_ALIGN(input_alignment_ch, compress)
    ch_msa_alignment = MAFFT_ALIGN.out.fas
    ch_versions = ch_versions.mix(MAFFT_ALIGN.out.versions)

    FASTTREE(ch_msa_alignment)
    ch_versions = ch_versions.mix(FASTTREE.out.versions)

    RAPIDNJ(ch_msa_alignment)
    ch_versions = ch_versions.mix(RAPIDNJ.out.versions)



    emit:
    versions = ch_versions

}
