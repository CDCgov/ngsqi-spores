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

    def filepath_true = reference && file(reference).exists() && file(reference).isFile()
    if (filepath_true) {
        ref_genome = Channel
            .value(reference)
            .map { input ->
                def meta = [id: file(input).baseName]
                return tuple(meta, file(input))
            }
    } else {
        genome_channel = Channel
            .value(reference)
            .map { input ->
                def meta = [id: input]
                return tuple(meta, file(input))
            }
        REFDOWNLOAD_SINGLE(genome_channel)
        ref_genome = REFDOWNLOAD_SINGLE.out.ref_genome
        versions = REFDOWNLOAD_SINGLE.out.versions
    }
 

    emit:
    ref_path                                // channel: [ val(ID), clade, var_id, chrom, pos, var_seq, [fastas] ]
    ref_fastas                             // channel: [ val(ID), [ fastas ] ]
    ref_genome                             // channel: [ val(ID), [ fasta ] ]
    versions = ch_versions                 // channel: [ versions.yml ]
}
