process ALTREFERENCE {
    tag "$accession"
    publishDir "${params.outdir}/references", mode: 'copy'

    input:
    tuple val(reference_id), val(clade), val(variant_id), val(chromosome), val(position), val(variant_seq), val(ref_file)
    path altreference_script

    output:
    tuple val(reference_id), val(ref_file), path("${reference_id}_${clade}_${variant_id}_altreference.fna"), emit: alt_genomes

    script:
    """
    python ${altreference_script} -i ${ref_file} -c ${chromosome} -p ${position} -s ${variant_seq} -o "${reference_id}_${clade}_${variant_id}_altreference.fna"
    """
}

