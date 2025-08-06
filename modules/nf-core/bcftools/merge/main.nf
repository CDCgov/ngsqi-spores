process BCFTOOLS_MERGE {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/5a/5acacb55c52bec97c61fd34ffa8721fce82ce823005793592e2a80bf71632cd0/data':
        'community.wave.seqera.io/library/bcftools:1.21--4335bec1d7b44d11' }"

    input:
    tuple val(meta), path(vcfs), path(csis)
    tuple val(meta2), path(fasta)

    output:
    tuple val(meta), path("*.{bcf,vcf}{,.gz}"), emit: vcf_merged
    //tuple val(meta), path("*.{bcf,vcf}{,.gz}"), path("*.{csi,tbi}"), emit: vcf_with_index
    path "versions.yml"                       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: '--force-samples -Oz'  // Default to compressed output
    def prefix = task.ext.prefix ?: "${meta.id}"

    def input = (vcfs.collect().size() > 1) ? vcfs.sort{ it.name } : vcfs
    def extension = args.contains("--output-type b") || args.contains("-Ob") ? "bcf.gz" :
                    args.contains("--output-type u") || args.contains("-Ou") ? "bcf" :
                    args.contains("--output-type z") || args.contains("-Oz") ? "vcf.gz" :
                    args.contains("--output-type v") || args.contains("-Ov") ? "vcf" :
                    "vcf.gz"  // Default to compressed

    // Determine if we need to create an index
    def needs_index = extension.endsWith(".gz") || extension.endsWith("bcf.gz")
    def index_type = extension.endsWith("vcf.gz") ? "tbi" : "csi"

    """
    bcftools merge \\
        $args \\
        --threads $task.cpus \\
        --gvcf $fasta \\
        --output ${prefix}.${extension} \\
        $input

    # Create index if output is compressed
    if [[ "${needs_index}" == "true" ]]; then
        bcftools index -t ${prefix}.${extension}
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bcftools: \$(bcftools --version 2>&1 | head -n1 | sed 's/^.*bcftools //; s/ .*\$//')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: '--force-samples -Oz'
    def prefix = task.ext.prefix ?: "${meta.id}"
    def extension = args.contains("--output-type b") || args.contains("-Ob") ? "bcf.gz" :
                    args.contains("--output-type u") || args.contains("-Ou") ? "bcf" :
                    args.contains("--output-type z") || args.contains("-Oz") ? "vcf.gz" :
                    args.contains("--output-type v") || args.contains("-Ov") ? "vcf" :
                    "vcf.gz"
    
    def needs_index = extension.endsWith(".gz") || extension.endsWith("bcf.gz")
    def index_ext = extension.endsWith("vcf.gz") ? "tbi" : "csi"
    def create_cmd = extension.endsWith(".gz") ? "echo '' | gzip >" : "touch"
    def create_index = needs_index ? "touch ${prefix}.${extension}.${index_ext}" : ""

    """
    ${create_cmd} ${prefix}.${extension}
    ${create_index}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bcftools: \$(bcftools --version 2>&1 | head -n1 | sed 's/^.*bcftools //; s/ .*\$//')
    END_VERSIONS
    """
}
