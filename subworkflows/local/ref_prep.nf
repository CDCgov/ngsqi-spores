/*
========================================================================================
    REFERENCE PREPARATION
========================================================================================
*/
include { REF_FORMAT } from '../../modules/local/ref_format.nf'
include { NUCMER } from '../../modules/nf-core/nucmer/main'
include { COORDSTOBED } from '../../modules/local/coordstobed.nf'
include { BEDTOOLS_MASKFASTA } from '../../modules/nf-core/bedtools/maskfasta/main'
//include { BWA_INDEX } from '../../modules/nf-core/modules/bwa/index/main'
//include { PICARD_CREATESEQUENCEDICTIONARY } from '../../modules/nf-core/modules/picard/createsequencedictionary/main'
//include { SAMTOOLS_FAIDX } from '../../modules/nf-core/modules/samtools/faidx/main'



workflow REF_PREP {
    take:
    fasta


    main:
    REF_FORMAT(fasta)
    ref = REF_FORMAT.out.ref_tuple
    
    NUCMER(ref)
    COORDSTOBED(NUCMER.out.delta)
    BEDTOOLS_MASKFASTA( COORDSTOBED.out.bed, fasta)

   emit:
   NUCMER.out.delta
   COORDSTOBED.out.bed
}