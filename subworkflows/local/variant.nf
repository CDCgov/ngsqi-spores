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

    // Combine each trimmed entry with the first fasta
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
        .view()
        .set { input_with_meta }
    
    // Extract just the fasta for indexing
    input_with_meta
        .map { meta, reads, fasta_file -> 
            // Create a simple meta for the fasta
            def fasta_meta = [id: fasta_file.baseName]
            return tuple(fasta_meta, fasta_file)
        }
        .unique()  // Only index each unique fasta once
        .set { ch_fasta_for_indexing }
    
    // Index the assembly FASTA
    SAMTOOLS_FAIDX(ch_fasta_for_indexing)
    ch_versions = ch_versions.mix(SAMTOOLS_FAIDX.out.versions)
    
    // Combine reads with fasta+index for medaka
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
    versions = ch_versions
}