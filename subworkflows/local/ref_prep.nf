/*
========================================================================================
    REFERENCE PREPARATION
========================================================================================
*/
//include { REFDOWNLOAD } from '../../modules/local/ref_download.nf'
include { REF_FORMAT } from '../../modules/local/ref_format.nf'
include { NUCMER } from '../../modules/nf-core/nucmer/main'
include { COORDSTOBED } from '../../modules/local/coordstobed.nf'
include { BEDTOOLS_MASKFASTA } from '../../modules/nf-core/bedtools/maskfasta/main'
include { BWA_INDEX } from '../../modules/nf-core/bwa/index/main'
include { PICARD_CREATESEQUENCEDICTIONARY as PICARD } from '../../modules/nf-core/picard/createsequencedictionary/main'
include { SAMTOOLS_FAIDX as SAMTOOLS} from '../../modules/nf-core/samtools/faidx/main'



workflow REF_PREP {
    take:
    ref_fastas

    main:
    ch_versions = Channel.empty()

    REF_FORMAT(ref_fastas)
    ref = REF_FORMAT.out.ref_tuple
    
    NUCMER(ref)
    ch_versions = ch_versions.mix(NUCMER.out.versions)
    delta = NUCMER.out.delta

    COORDSTOBED(delta)
    bed = COORDSTOBED.out.bed

    BEDTOOLS_MASKFASTA( bed, ref_fastas)
    masked = BEDTOOLS_MASKFASTA.out.fasta
    ch_versions = ch_versions.mix(BEDTOOLS_MASKFASTA.out.versions)

    BWA_INDEX(masked)
    ch_versions = ch_versions.mix(BWA_INDEX.out.versions)

    PICARD(masked)
    ch_versions = ch_versions.mix(PICARD.out.versions)

    SAMTOOLS(masked)
    ch_versions = ch_versions.mix(SAMTOOLS.out.versions)

   emit:
   delta
   bed
   masked
   versions = ch_versions
}