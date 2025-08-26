process COORDSTOBED {
    tag "$meta.id"
    label 'process_low'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mummer:3.23--pl5262h1b792b2_12' :
        'biocontainers/mummer:3.23--pl5262h1b792b2_12' }"

    input:
    tuple val(meta), path(filtered_delta)

    output:
    tuple val(meta), path("*_BEFORE_ORDER.bed"), emit: raw_coords
    tuple val(meta), path("*_BEFORE_ORDER2.bed"), emit: filtered_coords
    tuple val(meta), path("*_masked.bed"), emit: bed
    path "versions.yml", emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    show-coords -r -T -H $filtered_delta > ${prefix}_BEFORE_ORDER.bed

    awk '{if (\$1 != \$3 && \$2 != \$4) print \$0}' ${prefix}_BEFORE_ORDER.bed > ${prefix}_BEFORE_ORDER2.bed

    awk '{print \$8"\\t"\$1"\\t"\$2}' ${prefix}_BEFORE_ORDER2.bed > ${prefix}_masked.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
       mummer: \$( show-coords --version 2>&1 | head -n 1 | sed 's/^.*version //; s/ .*\$//' )
    END_VERSIONS

    touch ${prefix}_BEFORE_ORDER.bed
    touch ${prefix}_BEFORE_ORDER2.bed
    touch ${prefix}_masked.bed
    """
}
