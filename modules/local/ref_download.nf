process REFDOWNLOAD {
    tag "$accession"
    publishDir "${params.outdir}/ref_genomes", mode: 'copy'

    input:
    tuple val(reference_id), val(clade), val(variant_id), val(chromosome), val(position), val(variant_seq)
    path downloadgenome_script
    val ncbi_email
    val ncbi_api_key

    output:
    tuple val(reference_id), val(clade), val(variant_id), val(chromosome), val(position), val(variant_seq), path("${reference_id}_${clade}_${variant_id}_genomic.fna"), emit: genome_data
    path "${reference_id}_${clade}_${variant_id}_genomic.fna" 

    script:
    """
    export NCBI_API_KEY=${ncbi_api_key}
    export NCBI_EMAIL=${ncbi_email}
    python ${downloadgenome_script} ${reference_id}
    if [ -f "${reference_id}_genomic.fna.gz" ]; then
       gunzip -c "${reference_id}_genomic.fna.gz" > "${reference_id}_${clade}_${variant_id}_genomic.fna"
    else
       echo "Download failed for ${reference_id}"
       exit 1
    fi
    """
}


