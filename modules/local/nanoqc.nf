process NANOQC {
    tag "$meta.id"
    label 'process_low'

    input:
    tuple val(meta), path(ontfile)

    output:
    tuple val(meta), path("*.html")                , emit: html
    tuple val(meta), path("*.log")                 , emit: log
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
        -o . \\
        ${ontfile}

cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nanoqc: \$(nanoQC --version | sed 's/^.*nanoQC //; s/[^0-9.]//g')
END_VERSIONS
"""
}
