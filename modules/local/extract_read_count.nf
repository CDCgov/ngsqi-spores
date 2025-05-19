process EXTRACT_READ_COUNT {
    tag "${meta.id}"
    
    input:
    tuple val(meta), path(txt_file)
    
    output:
    tuple val(meta.id), env(number_of_reads), emit: read_counts
    
    script:
    """
    export number_of_reads=\$(grep "Number of reads:" "${txt_file}" | sed 's/Number of reads:\\s*//g' | tr -d ',' | cut -d'.' -f1)
    """
}