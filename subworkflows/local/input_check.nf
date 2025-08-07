//
// Check input samplesheet and get read channels
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    SAMPLESHEET_CHECK ( samplesheet )
        .csv
        .splitCsv ( header:true, sep:',' )
        .map { create_fastq_channel(it) }
        .set { reads }

    emit:
    reads                                     // channel: [ val(meta), [ reads ] ]
    versions = SAMPLESHEET_CHECK.out.versions // channel: [ versions.yml ]
}

// Function to get list of [ meta, [ fastq ] ] for single-end reads
def create_fastq_channel(LinkedHashMap row) {
    // create meta map
    def meta = [:]
    meta.id = row.sample

    // Check if the single FASTQ file exists
    if (!file(row.fastq).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> FASTQ file does not exist!\n${row.fastq}"
    }

    // Add the FASTQ file to the meta map
    def fastq_meta = [ meta, [ file(row.fastq) ] ]

    return fastq_meta
}
