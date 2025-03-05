/*
========================================================================================
    REFERENCE PREPARATION
========================================================================================
*/
include { REF_FORMAT } from '../../modules/local/ref_format.nf'
include { NUCMER } from '../../modules/nf-core/nucmer/main'
include { COORDSTOBED } from '../../modules/local/coordstobed.nf'
include { BEDTOOLS_MASKFASTA } from '../../modules/nf-core/bedtools/maskfasta/main'
include { BWA_INDEX } from '../../modules/nf-core/bwa/index/main'
include { PICARD_CREATESEQUENCEDICTIONARY as PICARD } from '../../modules/nf-core/picard/createsequencedictionary/main'
include { SAMTOOLS_FAIDX as SAMTOOLS} from '../../modules/nf-core/samtools/faidx/main'



workflow REF_PREP {
    take:
    fasta


    main:
    ch_versions = Channel.empty()
    ch_multiqc_files  = Channel.empty()

    REF_FORMAT(fasta)
    ref = REF_FORMAT.out.ref_tuple
    
    NUCMER(ref)
    ch_versions = ch_versions.mix(NUCMER.out.versions)

    COORDSTOBED(NUCMER.out.delta)

    BEDTOOLS_MASKFASTA( COORDSTOBED.out.bed, fasta)
    ch_versions = ch_versions.mix(BEDTOOLS_MASKFASTA.out.versions)

    BWA_INDEX(BEDTOOLS_MASKFASTA.out.fasta)
    ch_versions = ch_versions.mix(BWA_INDEX.out.versions)

    PICARD(BEDTOOLS_MASKFASTA.out.fasta)
    ch_versions = ch_versions.mix(PICARD.out.versions)

    SAMTOOLS(BEDTOOLS_MASKFASTA.out.fasta)
    ch_versions = ch_versions.mix(SAMTOOLS.out.versions)

   emit:
   NUCMER.out.delta
   COORDSTOBED.out.bed
   versions = ch_versions
}