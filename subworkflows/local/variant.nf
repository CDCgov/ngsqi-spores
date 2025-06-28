/*
========================================================================================
    VARIANT CALLING
========================================================================================
*/
include { SAMTOOLS_FAIDX } from '../../modules/nf-core/samtools/faidx/main'
include { MEDAKA } from '../../modules/nf-core/medaka/main'

workflow VARIANT_CALLING { 
    take:
    trimmed
    fastas

    main:
    ch_versions = Channel.empty()

    fastas
        .filter { reference, clade, var_id, chrom, pos, var_seq, fasta_file ->
            clade == "1" 
        }
        .first()
        .set { ch_first_fasta }

    trimmed
        .combine(ch_first_fasta)
        .map { meta, reads, reference, clade, var_id, chrom, pos, var_seq, fasta_file ->
            def combined_meta = meta + [
                id: reads.baseName.replaceAll(/(_chopped_chopper)?\.fastq(\.gz)?$/, ''),
                valID: reference,
                clade: clade, 
                var_id: var_id,
                chrom: chrom,
                pos: pos,
                var_seq: var_seq
            ]
            return tuple(combined_meta, reads, fasta_file)
        }
        .set { input_with_meta }

    input_with_meta
        .map { meta, reads, fasta -> tuple(meta, fasta) }
        .set { meta_fasta_only }
    
    input_with_meta
        .map { meta, reads, fasta_file -> 
            def fasta_meta = [id: fasta_file.baseName]
            return tuple(fasta_meta, fasta_file)
        }
        .unique()
        .set { ch_fasta_for_indexing }
    
    SAMTOOLS_FAIDX(ch_fasta_for_indexing)
    ch_versions = ch_versions.mix(SAMTOOLS_FAIDX.out.versions)
    
    input_with_meta
        .map { meta, reads, fasta_file -> 
            def fasta_meta = [id: fasta_file.baseName]
            return tuple(fasta_meta, meta, reads, fasta_file)
        }
        .combine(SAMTOOLS_FAIDX.out.fai, by: 0)
        .map { fasta_meta, meta, reads, fasta_file, fai ->
            return tuple(meta, reads, [fasta_file, fai])
        }
        .set { ch_medaka_input }

    MEDAKA(ch_medaka_input)
    medaka_variants = MEDAKA.out.vcf
    ch_versions = ch_versions.mix(MEDAKA.out.versions)

    emit:
    medaka_variants
    meta_fasta_only
    versions = ch_versions
}