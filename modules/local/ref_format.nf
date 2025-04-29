process REF_FORMAT {
    input:
    tuple val(meta), path(fastas)

    output:
    tuple val(meta), path("reference.fasta"), path("reference.copy.fasta"), emit: ref_tuple

    script:
    meta = ["id": 'reference']

    """
    echo ${meta.id}
    cp ${fastas} reference.fasta
    cp reference.fasta reference.copy.fasta

    """
}
