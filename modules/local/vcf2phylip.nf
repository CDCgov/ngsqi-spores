process VCF2PHYLIP {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9' :
        'biocontainers/python:3.9' }"

    input:
    tuple val(meta), path(vcf)

    output:
    tuple val(meta), path("*.fasta"), emit: fasta
    path "versions.yml",              emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    vcf2phylip.py \\
        --input ${vcf} \\
        --output-prefix ${prefix} \\
        --fasta \\
        --phylip-disable \\
        -m 1 \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vcf2phylip: 2.9
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}_min4.fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vcf2phylip: 2.9
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
