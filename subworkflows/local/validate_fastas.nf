// Check input samplesheet and get read channels
include { FASTA_CHECK } from '../../modules/local/fasta_check'
include { REFDOWNLOAD } from '../../modules/local/refdownload.nf'
include { REFDOWNLOAD_SINGLE } from '../../modules/local/refdownload_single.nf'


workflow VALIDATE_FASTAS {
    take:
    fasta_samplesheet
    reference
    ncbi_email
    ncbi_api_key

    main:
    ch_versions = Channel.empty()

    FASTA_CHECK ( fasta_samplesheet )
    ch_versions = ch_versions.mix(FASTA_CHECK.out.versions)

    if (params.mode == 'local') {
        FASTA_CHECK.out.csv
            .splitCsv(header: true, sep: ',')
            .map { row ->
                tuple(
                    row.reference,
                    row.clade,
                    row.var_id,
                    row.chrom,
                    row.pos,
                    row.var_seq,
                    file(row.file_path)
                )
            }
            .set { ref_path }

        ref_path.map { row -> tuple([id: row[0]], row[6]) }
            .set { ref_fastas }

    } else {
        FASTA_CHECK.out.csv
            .splitCsv(header: true, sep: ',')
            .map { row ->
                tuple(
                    row.reference,
                    row.clade,
                    row.var_id,
                    row.chrom,
                    row.pos,
                    row.var_seq
                )
            }
            .set { fastas }

        REFDOWNLOAD(fastas, ncbi_email, ncbi_api_key)

        REFDOWNLOAD.out.genome_data.set { ref_path }
        ch_versions = ch_versions.mix(REFDOWNLOAD.out.versions)

        ref_path.map { row -> tuple([id: row[0]], row[6]) }
            .set { ref_fastas }
    }

    REFDOWNLOAD_SINGLE(reference, ncbi_email, ncbi_api_key)

    ref_genome = REFDOWNLOAD_SINGLE.out.ref_genome
        .map {accession, reference ->
            def meta = tuple([ id: accession], reference) }

    emit:
    ref_path                                // channel: [ val(ID), clade, var_id, chrom, pos, var_seq, [fastas] ]
    ref_fastas                             // channel: [ val(ID), [ fastas ] ]
    ref_genome                             // channel: [ val(ID), [ fasta ] ]
    versions = ch_versions                 // channel: [ versions.yml ]
}
