// Check input samplesheet and get read channels

include { FASTA_CHECK } from '../../modules/local/fasta_check'

workflow VALIDATE_FASTAS {
    take:
    fasta_samplesheet // file: /path/to/fasta_samplesheet.csv

    main:
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

    fastas.map { row -> tuple([id: row[0]], row[1]) } 
        .set { ref_fastas }



    emit:
    fastas                                // channel: [ val(ID), clade, var_id, chrom, pos, var_seq ]
    ref_fastas                             // channel: [ val(ID), [ fastas ] ]
    versions = FASTA_CHECK.out.versions        // channel: [ versions.yml ]
}
