process NANOSIMSIMULATION {
    container "/scicomp/home-pure/xvp4/spores/third_party/nanosim.sif"
    tag "sample: ${sample_id} ref: ${ID}"

    cpus 8

    input:
    tuple val(sample_id), val(reference), path(model_dir), val(model_prefix), val(ID), path(ref_file), path(alt_ref), val(number_of_reads)

    output:
    tuple val(sample_id), val(ID), path("${sample_id}_${ID}_aligned_reads.fastq.gz"), emit: nanosim_output
    path "${sample_id}_${ID}*.log", emit: log_files
    path "versions.yml", emit: versions
    
    script:
    """
    # Run simulator
    simulator.py genome \\
      -rg "${alt_ref}" \\
      -c "${model_prefix}" \\
      -n "${number_of_reads}" \\
      -t 9 \\
      --fastq \\
      -o "${sample_id}_${ID}_nanosim" \\
      > "${sample_id}_${ID}_outputsim.log" \\
      2> "${sample_id}_${ID}_errorsim.log"

    # Find the aligned reads file and check if it exists before copying
    ALIGNED_FILE=\$(find . -name "${sample_id}_${ID}_nanosim*aligned*reads.fastq" | head -n 1)
    
    if [ -n "\$ALIGNED_FILE" ] && [ -f "\$ALIGNED_FILE" ]; then
        # Compress the file with gzip and save directly to the target filename
        gzip -c "\$ALIGNED_FILE" > "${sample_id}_${ID}_aligned_reads.fastq.gz"
        echo "Compressed \$ALIGNED_FILE to ${sample_id}_${ID}_aligned_reads.fastq.gz" >> "${sample_id}_${ID}_outputsim.log"
    else
        echo "ERROR: Could not find aligned reads file" >&2
        echo "Files in working directory:" >&2
        find . -type f -name "*.fastq" >&2
        exit 1
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nanosim_simulation: \$(echo \$(read_analysis.py -v 2>&1) | sed 's/^.*nanosim //; s/Using.*\$//')
    END_VERSIONS
    """
}
