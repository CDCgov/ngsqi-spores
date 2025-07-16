/*
========================================================================================
    VARIANT CALLING
========================================================================================
*/

include { MEDAKA } from '../../modules/nf-core/medaka/main'

workflow VARIANT_CALLING {
    take:
    trimmed         // Channel: tuple val(meta), path("*_chopper.fastq.gz")
    fastas          // Channel: tuple(reference, clade, var_id, chrom, pos, var_seq, fasta_file)
    masked          // Channel: tuple val(meta), path("*.fa") — masked FASTA
    fai             // Channel: tuple val(meta), path("*.fai") — index for masked FASTA

    main:
    ch_versions = Channel.empty()

    //Filter clade I entries
    clade1_fastas = fastas
        .filter { reference, clade, var_id, chrom, pos, var_seq, fasta_file ->
            clade == "1"
        }
        .map { reference, clade, var_id, chrom, pos, var_seq, fasta_file ->
            def meta = [ id: reference ]
            tuple([id: reference], meta)
        }

    //Match masked FASTA and .fai index using clade I ID
    clade1_masked = clade1_fastas
        .combine(masked, by: 0)
        .map { id, meta, fasta_file -> tuple([id: meta.id], meta, fasta_file) }
        .combine(fai, by: 0)
        .map { id, meta, fasta_file, fai_file -> tuple(meta, [fasta_file, fai_file]) }

    //Pair each trimmed read with the reference+index
    ch_medaka_input = trimmed
        .combine(clade1_masked)
        .map { read_meta, reads, ref_meta, reference_bundle ->
            tuple(read_meta, reads, reference_bundle)
        }

    //Run Medaka
    MEDAKA(ch_medaka_input)
    medaka_variants = MEDAKA.out.vcf
    ch_versions = ch_versions.mix(MEDAKA.out.versions)

    emit:
    medaka_variants
    clade1_fastas
    versions = ch_versions
}
