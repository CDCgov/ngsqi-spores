process REFDOWNLOAD_SINGLE {
    container 'quay.io/biocontainers/biopython:1.79'

    input:
    tuple val(meta), file(reference)
    
    output:
    tuple val(meta), path("${reference}.fna"), emit: ref_genome
    path "${reference}.fna"
    path "versions.yml", emit: versions

    script:
    """
    # Set API credentials
    export NCBI_API_KEY="${params.ncbi_api_key}"
    export NCBI_EMAIL="${params.ncbi_email}"

    # Run the download script
    download_genome_single.py ${reference}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python_altreference: \$(echo \$(python --version 2>&1) | sed 's/^.*python //; s/Using.*\$//')
    END_VERSIONS
    """
}