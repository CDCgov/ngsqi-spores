

process FAMSA_DIST {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/famsa:2.2.2--h9f5acd7_0':
        'biocontainers/famsa:2.2.2--h9f5acd7_0' }"

    input:
    tuple val(meta) , path(fasta)
    val(compress)

    output:
   
    tuple val(meta), path("*.csv{.gz,}"), emit: alignment
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def compress_args = compress ? '-gz' : ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
     famsa \\
        $compress_args \\
        $args \\
        -t 32 \\
        -dist_export \\
        ${fasta} \\
        ${prefix}.csv ${compress ? '.gz':''}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        famsa: \$( famsa -help 2>&1 | head -n 2 | tail -n 1 | sed 's/ version //g' )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.csv${compress ? '.gz' : ''}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        famsa: \$( famsa -help 2>&1 | head -n 2 | tail -n 1 | sed 's/ version //g' )
    END_VERSIONS
    """
}
