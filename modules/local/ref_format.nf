process REF_FORMAT {
    input:
    path(fasta)

    output:
    tuple val(meta), path("reference.fasta"), path("reference.copy.fasta"), emit: ref_tuple

    script:
    meta = ["id": 'reference']

    """
    echo ${meta.id}
    cp ${fasta} reference.fasta
    cp reference.fasta reference.copy.fasta

    """
}
