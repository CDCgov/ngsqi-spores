process REFDOWNLOAD_SINGLE {
    container 'quay.io/biocontainers/biopython:1.79'

    input:
    val reference
    val ncbi_email
    val ncbi_api_key

    output:
    tuple val(reference), path("${reference}.fna"), emit: ref_genome
    path "${reference}.fna"
    path "versions.yml", emit: versions

    script:
    """
    export NCBI_API_KEY="${ncbi_api_key}"
    export NCBI_EMAIL="${ncbi_email}"

    download_genome_single.py '${reference}'

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python_altreference: \$(echo \$(python --version 2>&1) | sed 's/^.*python //; s/Using.*\$//')
    END_VERSIONS
    """
}

