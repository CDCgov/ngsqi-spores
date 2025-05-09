process NANOSIMSIMULATION {
    container "/scicomp/home-pure/xvp4/spores/third_party/nanosim.sif"
    tag "sample: ${sample_id} ref: ${ID}"

    input:
    tuple val(sample_id), val(reference), path(model_dir), val(model_prefix), val(ID), path(ref_file), path(alt_ref)

    output:
    tuple val(sample_id), val(ID), path("aligned_reads/${sample_id}_${ID}_aligned_reads.fastq"), emit: nanosim_output
    path "${sample_id}_${ID}*.log", emit: log_files
    path "versions.yml", emit: versions
    
    script:
    """
    # Run simulator
    simulator.py genome \\
      -rg "${alt_ref}" \\
      -c "${model_prefix}" \\
      -n 2513550 \\
      -t 9 \\
      --fastq \\
      -o "${sample_id}_${ID}_nanosim" \\
      > "${sample_id}_${ID}_outputsim.log" \\
      2> "${sample_id}_${ID}_errorsim.log"

    # Create a directory for the aligned reads
    mkdir -p aligned_reads/
    
    # Find the aligned reads file and copy it to a standard location
    cp \$(find . -name "${sample_id}_${ID}_nanosim*aligned*reads.fastq") aligned_reads/${sample_id}_${ID}_aligned_reads.fastq
    
    # Verify the file exists
    if [ ! -f "aligned_reads/${sample_id}_${ID}_aligned_reads.fastq" ]; then
        echo "ERROR: Could not find aligned reads file" >&2
        echo "Files in working directory:" >&2
        ls -la >&2
        exit 1
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nanosim_simulation: \$(echo \$(simulator.py -v 2>&1) | sed 's/^.*nanosim //; s/Using.*\$//')
    END_VERSIONS
    """
}