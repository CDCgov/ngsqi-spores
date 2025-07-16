process COMBINE_CONSENSUS {
    publishDir "${params.outdir}/phylogeny", mode: 'copy'
    
    input:
    tuple val(meta), path(consensus_files)
    
    output:
    tuple val(meta), path("all_samples_consensus.fa"), emit: multi_fasta
    
    script:
    """
    cat ${consensus_files.join(' ')} > all_samples_consensus.fa
    """
}
