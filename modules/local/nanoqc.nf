process NANOQC {
    tag "$meta.id"
    label 'process_low'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/nanoqc:0.10.0--pyhdfd78af_0' :
        'biocontainers/nanoqc:0.10.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(fastq)

    output:
    tuple val(meta), path("*.html")                , emit: html
    tuple val(meta), path("*.log")                 , emit: log
    path  "versions.yml"                                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def input_file = ("$fastq".endsWith(".fastq.gz") || "$fastq".endsWith(".fq.gz")) ? "${fastq}" :
        ("$fastq".endsWith(".txt")) ? "--summary ${fastq}" : ''
    """
    nanoQC \\
        $args \\
        -o . \\
        ${fastq}

cat <<-END_VERSIONS > versions.yml
"${task.process}":
    nanoqc: \$(nanoQC --version | sed 's/^.*nanoQC //; s/[^0-9.]//g')
END_VERSIONS
"""
}
