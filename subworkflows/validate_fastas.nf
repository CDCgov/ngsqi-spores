// Check input samplesheet and get read channels

include { FASTA_CHECK } from '../../modules/local/fasta_check'

workflow VALIDATE_FASTAS {
    take:
    fastas // file: /path/to/fasta_samplesheet.csv

    main:
    VALIDATE_FASTAS ( fastas )
        .csv
        .splitCsv(header: true, sep: ',')
        .map { row -> 
            tuple(
                row.fasta,
                row.chrom,
                row.pos,
                row.new_seq
            ) 
        }
        .set { ch_fastas }

    emit:
    ch_fastas                                // channel: [ val(ID), [ fastas ] ]
    versions = VALIDATE_FASTAS.out.versions        // channel: [ versions.yml ]
}
