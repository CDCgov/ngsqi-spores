process REFDOWNLOAD {
    container 'quay.io/biocontainers/biopython:1.79'
    tag "$reference_id"
    publishDir "${params.outdir}/ref_genomes", mode: 'copy'
    
    input:
    tuple val(reference_id), val(clade), val(variant_id), val(chromosome), val(position), val(variant_seq)
    path download_script
    val ncbi_email
    val ncbi_api_key
    
    output:
    tuple val(reference_id), val(clade), val(variant_id), val(chromosome), val(position), val(variant_seq), path("${reference_id}_${clade}_${variant_id}_genomic.fna"), emit: genome_data
    path "${reference_id}_${clade}_${variant_id}_genomic.fna" 
    
    script:
    """
    # Set API credentials
    export NCBI_API_KEY="${ncbi_api_key}"
    export NCBI_EMAIL="${ncbi_email}"
    
    # Run the download script
    python ${download_script} ${reference_id}
    
    if [ -f "${reference_id}_genomic.fna.gz" ]; then
       gunzip -c "${reference_id}_genomic.fna.gz" > "${reference_id}_${clade}_${variant_id}_genomic.fna"
    else
       echo "Download failed for ${reference_id}"
       exit 1
    fi
    """
}