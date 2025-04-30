process REF_FORMAT {
    input:
    tuple val(meta), path(fastas)

    output:
    tuple val(meta), path("*.fasta"), path("*.copy.fasta"), emit: ref_tuple

    script:
    """
    echo "Processing reference: ${meta.id}"
    cp ${fastas} ${meta.id}.fasta
    cp ${meta.id}.fasta ${meta.id}.copy.fasta
    """
}
