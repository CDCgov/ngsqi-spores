process NANOQC {
    tag "$meta.id"
    label 'process_low'

    input:
    tuple val(meta), path(ontfile)

    output:
    tuple val(meta), path("read1/*.html")                , emit: html_1
    tuple val(meta), path("read1/*.log")                 , emit: log_1
    tuple val(meta), path("read2/*.html")                , emit: html_2
    tuple val(meta), path("read2/*.log")                 , emit: log_2
    path  "versions.yml"                                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def input_file = ("$ontfile".endsWith(".fastq.gz") || "$ontfile".endsWith(".fq.gz")) ? "${ontfile}" :
        ("$ontfile".endsWith(".txt")) ? "--summary ${ontfile}" : ''
    """
    nanoQC \\
        $args \\
        -o read1 \\
        ${ontfile[0]}

    nanoQC \\
        $args \\
        -o read2 \\
        ${ontfile[1]}

cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nanoqc: \$(nanoQC --version | sed 's/^.*nanoQC //; s/[^0-9.]//g')
END_VERSIONS
"""
}
