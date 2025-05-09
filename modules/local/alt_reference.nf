process ALTREFERENCE {
    container 'quay.io/biocontainers/biopython:1.79' 
    tag "$ID"
    publishDir "${params.outdir}/references", mode: 'copy'

    input:
    tuple val(ID), val(clade), val(var_id), val(chrom), val(pos), val(var_seq), path(ref_file)
    path altreference_script

    output:
    tuple val(ID), path(ref_file), path("${ID}_${clade}_${var_id}_altreference.fna"), emit: alt_genomes

    script:
    """
    python ${altreference_script} -i ${ref_file} -c ${chrom} -p ${pos} -s ${var_seq} -o "${ID}_${clade}_${var_id}_altreference.fna"
    """
}

