process SNPEFF_SNPEFF {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/snpeff:5.2--hdfd78af_1' :
        'biocontainers/snpeff:5.2--hdfd78af_1' }"

    input:
    tuple val(meta), path(vcf)
    path   snpeff_dir, stageAs: 'snpeffdb'
    path   config               

    output:
    tuple val(meta), path("*.ann.vcf"),   emit: vcf
    tuple val(meta), path("*.csv"),       emit: report
    tuple val(meta), path("*.html"),      emit: summary_html
    tuple val(meta), path("*.genes.txt"), emit: genes_txt
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def avail_mem = 6144
    if (!task.memory) {
        log.info '[snpEff] Available memory not known - defaulting to 6GB.'
    } else {
        avail_mem = (task.memory.mega*0.8).intValue()
    }
    def prefix = task.ext.prefix ?: "${meta.id}"
    def db_name = params.snpeffdb_name ?: "candida_auris_gca_016772135.1"
    
    """
    # Run SnpEff
    snpEff \\
        -Xmx${avail_mem}M \\
        -c snpEff.config \\
        ${args} \\
        -csvStats ${prefix}.csv \\
        ${db_name} \\
        ${vcf} \\
        > ${prefix}.ann.vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        snpeff: \$(echo \$(snpEff -version 2>&1) | cut -f 2 -d ' ')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.ann.vcf
    touch ${prefix}.csv
    touch ${prefix}.html
    touch ${prefix}.genes.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        snpeff: \$(echo \$(snpEff -version 2>&1) | cut -f 2 -d ' ')
    END_VERSIONS
    """
}