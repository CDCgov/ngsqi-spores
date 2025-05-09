process COORDSTOBED {
    tag "$meta.id"
    label 'process_low'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mummer:3.23--pl5262h1b792b2_12' :
        'biocontainers/mummer:3.23--pl5262h1b792b2_12' }"

    input:
    tuple val(meta), path(delta)

    output:
    tuple val(meta), path("*.bed"), emit: bed

    script:
    """
    show-coords -rcl ${delta} > alignment.coords

    # Debug: Check if coords file is created and contains data
    if [[ ! -s alignment.coords ]]; then
        echo "Error: alignment.coords is empty or not created."
        exit 1
    fi

    # Convert coordinates to BED format
    awk 'BEGIN{OFS="\t"} NR>5 && \$1 != "=" {print \$18, \$1, \$2}' alignment.coords > alignment.bed

    # Debug: Check if BED file is properly formatted
    if [[ ! -s alignment.bed ]]; then
        echo "Error: alignment.bed is empty or not created."
        exit 1
    fi

    # Check BED file format
    first_line=\$(head -n 1 alignment.bed)
    num_columns=\$(echo \$first_line | awk '{print NF}')

    if [[ \$num_columns -lt 3 ]]; then
        echo "Error: alignment.bed has less than 3 columns."
        exit 1
    fi

    mv alignment.bed ${meta.id}.bed
    """
}
