process REFDOWNLOAD_SINGLE {
    container 'quay.io/biocontainers/biopython:1.79'

    input:
    val reference_genome
    path download_script_single
    val ncbi_email
    val ncbi_api_key

    output:
    tuple val(reference_genome), path("${reference_genome}.fna"), emit: genome_data_ref
    path "${reference_genome}.fna"
    path "versions.yml", emit: versions

    script:
    """
    # Set API credentials
    export NCBI_API_KEY="${ncbi_api_key}"
    export NCBI_EMAIL="${ncbi_email}"

    # Run the download script
    python ${download_script_single} '${reference_genome}'

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python_altreference: \$(echo \$(python --version 2>&1) | sed 's/^.*nanosim //; s/Using.*\$//')
    END_VERSIONS
    """
}

