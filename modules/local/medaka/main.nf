process MEDAKA {
    tag "$meta.id"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/medaka:2.0.1--py310he807b20_0' :
        'biocontainers/medaka:2.0.1--py310he807b20_0' }"

    input:
    tuple val(meta), path(reads), path(assembly_files)  // [fasta, fai]

    output:
    tuple val(meta), path("${meta.id}/medaka.annotated.vcf"), emit: vcf
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def assembly = assembly_files[0]
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    medaka_variant \\
        -t $task.cpus \\
        $args \\
        -i $reads \\
        -r $assembly \\
        -m r1041_e82_400bps_hac_variant_v4.3.0 \\
        -o ${prefix}

    # Replace SAMPLE header with the actual sample name in the VCF file
    sed 's/\\tSAMPLE\$/\\t${prefix}/' ${prefix}/medaka.annotated.vcf > ${prefix}/medaka.annotated.vcf.tmp
    mv ${prefix}/medaka.annotated.vcf.tmp ${prefix}/medaka.annotated.vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        medaka: \$( medaka --version 2>&1 | sed 's/medaka //g' )
    END_VERSIONS
    """
}
