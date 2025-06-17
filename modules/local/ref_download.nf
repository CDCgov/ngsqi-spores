process REFDOWNLOAD {
    container 'quay.io/biocontainers/biopython:1.79'
    
    input:
    tuple val(reference), val(clade), val(var_id), val(chrom), val(pos), val(var_seq)
    path download_script
    val ncbi_email
    val ncbi_api_key
    
    output:
    tuple val(reference), val(clade), val(var_id), val(chrom), val(pos), val(var_seq), path("${reference}_${clade}_${var_id}_genomic.fna"), emit: genome_data
    path "${reference}_${clade}_${var_id}_genomic.fna"
    path "versions.yml", emit: versions
    
    script:
    """
    # Set API credentials
    export NCBI_API_KEY="${ncbi_api_key}"
    export NCBI_EMAIL="${ncbi_email}"
    
    # Run the download script
    python ${download_script} ${reference} ${clade} ${var_id}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python_altreference: \$(echo \$(python --version 2>&1) | sed 's/^.*nanosim //; s/Using.*\$//')
    END_VERSIONS
    """
}