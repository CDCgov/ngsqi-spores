/*
========================================================================================
    INPUT CHECK
========================================================================================
*/

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'

workflow INPUT_CHECK {
    take:
    samplesheet

    main:
    SAMPLESHEET_CHECK ( samplesheet )
        .csv
        .splitCsv ( header:true, sep:',' )
        .map { create_fastq_channel(it) }
        .set { reads }

    emit:
    reads                                     
    versions = SAMPLESHEET_CHECK.out.versions 
}

def create_fastq_channel(LinkedHashMap row) {
    def meta = [:]
    meta.id = row.sample

    if (!file(row.fastq).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> FASTQ file does not exist!\n${row.fastq}"
    }

    def fastq_meta = [ meta, [ file(row.fastq) ] ]

    return fastq_meta
}
