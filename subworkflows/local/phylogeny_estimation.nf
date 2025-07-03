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

    input_alignment_ch
    compress

    main:

    ch_versions = Channel.empty()

    MAFFT_ALIGN(input_alignment_ch, compress)
    ch_msa_alignment=MAFFT_ALIGN.out.fas
    ch_versions = ch_versions.mix(MAFFT_ALIGN.out.versions)
    
    FASTTREE(ch_msa_alignment)
    ch_fast= FASTTREE.out.phylogeny
    ch_versions = ch_versions.mix(FASTTREE.out.versions)
    
    RAPIDNJ(ch_msa_alignment)
    ch_rapid= RAPIDNJ.out.phylogeny
    ch_nj= RAPIDNJ.out.stockholm_alignment
    ch_versions = ch_versions.mix(RAPIDNJ.out.versions)
   


    emit:

    versions = ch_versions
    MAFFT_ALIGN.out.fas
    FASTTREE.out.phylogeny
    RAPIDNJ.out.phylogeny
    MAFFT_ALIGN.out.versions
    //FASTTREE.out.versions
    //RAPIDNJ.out.versions
    // RAPIDNJ.out.stockholm_alignment

}
