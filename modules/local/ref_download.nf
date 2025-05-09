process REFDOWNLOAD {
    container 'quay.io/biocontainers/biopython:1.79'
    publishDir "${params.outdir}/ref_genomes", mode: 'copy'
    
    input:
    tuple val(reference), val(clade), val(var_id), val(chrom), val(pos), val(var_seq)
    path download_script
    val ncbi_email
    val ncbi_api_key
    
    output:
    tuple val(reference), val(clade), val(var_id), val(chrom), val(pos), val(var_seq), path("${reference}_${clade}_${var_id}_genomic.fna"), emit: genome_data
    path "${reference}_${clade}_${var_id}_genomic.fna" 
    
    script:
    """
    # Set API credentials
    export NCBI_API_KEY="${ncbi_api_key}"
    export NCBI_EMAIL="${ncbi_email}"
    
    # Run the download script
    python ${download_script} ${reference} ${clade} ${var_id}
    """
}