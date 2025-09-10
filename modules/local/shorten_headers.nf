process SHORTENHEADERS {

    input:
    tuple val(ref_id), path(ref_path), path(alt_ref_path), val(sample_id), path(fastq), val(clade), val(var_id)

    output:
    tuple val(sample_id), val(ref_id), path("shortened_${fastq.baseName}.fastq"), val(clade), val(var_id), emit: shortened_fastq

    script:
    """
    gunzip -c "${fastq}" | awk '{if(NR % 4 == 1 || NR % 4 == 3) {sub(/ .*/,""); print} else print}' > "shortened_${fastq.baseName}.fastq"
    """
}
