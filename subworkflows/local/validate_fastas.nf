// Check input samplesheet and get read channels
include { FASTA_CHECK } from '../../modules/local/fasta_check'
include { REFDOWNLOAD } from '../../modules/local/ref_download.nf'


workflow VALIDATE_FASTAS {
    take:
    fasta_samplesheet // file: /path/to/fasta_samplesheet.csv
    download_script
    ncbi_email
    ncbi_api_key

    main:
    ch_versions = Channel.empty()

        FASTA_CHECK ( fasta_samplesheet )
        .csv
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


    ch_versions = ch_versions.mix(FASTA_CHECK.out.versions)

    REFDOWNLOAD(fastas, download_script, ncbi_email, ncbi_api_key)
    ref_path=REFDOWNLOAD.out.genome_data
    ch_versions = ch_versions.mix(REFDOWNLOAD.out.versions)

    ref_path.map { row -> tuple([id: row[0]], row[6]) } 
        .set { ref_fastas }


    emit:
    ref_path                                // channel: [ val(ID), clade, var_id, chrom, pos, var_seq, [fastas] ]
    ref_fastas                             // channel: [ val(ID), [ fastas ] ]
    versions = ch_versions        // channel: [ versions.yml ]
}
