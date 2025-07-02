process MAFFT_ALIGN {
    tag "$meta.id"
    label 'process_high'
   
    conda "${moduleDir}/environment.yml"
    container "https://depot.galaxyproject.org/singularity/mafft:7.221--0"

    input:
    tuple val(meta), path(fasta)
    val(compress)

    output:
    tuple val(meta), path("*.fas"), emit: fas
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args         = task.ext.args   ?: ''
    def prefix       = task.ext.prefix ?: "${meta.id}"
   // def add          = add             ? "--add ${add}"                   : ''
    def write_output = compress ? " | pigz -cp ${task.cpus} > ${prefix}.fas.gz" : "> ${prefix}.fas"

    """
    mafft \\
        --thread ${task.cpus} \\
        --localpair \\
        --maxiterate 1000 \\
        ${fasta} \\
        ${write_output}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mafft: \$(mafft --version 2>&1 | sed 's/^v//' | sed 's/ (.*)//')
        pigz: \$(echo \$(pigz --version 2>&1) | sed 's/^.*pigz\\w*//' ))
    END_VERSIONS

    """

    stub:
    def args         = task.ext.args   ?: ''
    def prefix       = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.fas${compress ? '.gz' : ''}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mafft: \$(mafft --version 2>&1 | sed 's/^v//' | sed 's/ (.*)//')
        pigz: \$(echo \$(pigz --version 2>&1) | sed 's/^.*pigz\\w*//' ))
    END_VERSIONS
    """

}
