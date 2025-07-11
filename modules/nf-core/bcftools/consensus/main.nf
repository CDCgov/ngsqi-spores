process BCFTOOLS_CONSENSUS {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry-v2/blobs/sha256/5a/5acacb55c52bec97c61fd34ffa8721fce82ce823005793592e2a80bf71632cd0/data':
        'community.wave.seqera.io/library/bcftools:1.21--4335bec1d7b44d11' }"

    input:
    tuple val(meta), file(vcf), file(tbi), file(fasta)

    output:
    tuple val(meta), path("${meta.id}.fa"), emit: fasta
    path  "versions.yml"         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    # Create consensus sequence by applying VCF variants to reference
    bcftools consensus $vcf < $fasta > temp_consensus.fa 2> consensus.log

    # Verify all chromosomes are present
    if [ \$(grep -c ">" temp_consensus.fa) -ne 7 ]; then
        echo "ERROR: Expected 7 chromosomes, got \$(grep -c ">" temp_consensus.fa)"
        echo "Bcftools log:"
        cat consensus.log
        exit 1
    fi

    # Fix headers
    sed "s/^>/>${prefix}_/" temp_consensus.fa > ${prefix}.fa

    # IMPORTANT: Remove temp file to avoid confusion
    rm temp_consensus.fa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bcftools: \$(bcftools --version 2>&1 | head -n1 | sed 's/^.*bcftools //; s/ .*\$//')
    END_VERSIONS
    """
}