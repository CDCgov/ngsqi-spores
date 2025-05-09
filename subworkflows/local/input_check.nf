//
// Check input samplesheet and get read channels
//
include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    SAMPLESHEET_CHECK(samplesheet)
        .csv
        .splitCsv(header:true, sep:',')
        .map { row -> 
            // Check if the FASTQ file exists
            if (!file(row.fastq).exists()) {
                exit 1, "ERROR: Please check input samplesheet -> FASTQ file does not exist!\n${row.fastq}"
            }
            
            // Return the individual components we need
            def sample_id = row.sample
            def fastq_file = file(row.fastq)
            
            return [sample_id, fastq_file]
        }
        .multiMap { sample_id, fastq_file ->
            // Create a channel with id prefix + sample
            reads_meta: [ [id: sample_id], fastq_file ]
            
            // Create a channel with just the sample
            reads_simple: [ sample_id, fastq_file ]
        }
        .set { ch_reads }

    emit:
    reads = ch_reads.reads_meta   // channel: [ val(id_sample), path(fastq) ]
    reads_simple = ch_reads.reads_simple     // channel: [ val(sample), path(fastq) ]
    versions = SAMPLESHEET_CHECK.out.versions // channel: [ versions.yml ]
}