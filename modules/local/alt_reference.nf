process ALTREFERENCE {
    container 'quay.io/biocontainers/biopython:1.79' 
    tag "$ID"

    input:
    tuple val(ID), val(clade), val(var_id), val(chrom), val(pos), val(var_seq), path(ref_file)
    path altreference_script

    output:
    tuple val(ID), path(ref_file), val(clade), val(var_id), path("${ID}_${clade}_${var_id}_altreference.fna"), emit: alt_genomes
    path "versions.yml", emit: versions

    script:
    """
    python ${altreference_script} -i ${ref_file} -c ${chrom} -p ${pos} -s ${var_seq} -o "${ID}_${clade}_${var_id}_altreference.fna"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}

