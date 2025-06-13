process NANOSIMSIMULATION {
    container "${projectDir}/third_party/nanosim.sif"
    tag "sample: ${sample_id} ref: ${ID}"

    cpus 8

    input:
    tuple val(sample_id), val(reference), path(model_dir), val(model_prefix), val(ID), path(ref_file), path(alt_ref), val(number_of_reads), val(clade), val(var_id)

    output:
    tuple val(sample_id), val(ID), path("${sample_id}_${ID}_${clade}_${var_id}_aligned_reads.fastq.gz"), val(clade), val(var_id), emit: nanosim_output
    path "${sample_id}_${ID}_${clade}_${var_id}*.log", emit: log_files
    path "versions.yml", emit: versions
    
    script:
    """
    # Copy model files from model directory to current working directory
    cp ${model_dir}/${model_prefix}* .

    # List what we have for debugging
    echo "Model files copied:"
    ls -la *${model_prefix}*

    #Run simulator
    simulator.py genome \\
    -rg "${alt_ref}" \\
    -c "${model_prefix}" \\
    -n "${number_of_reads}" \\
    -t 9 \\
    --fastq \\
    -o "${sample_id}_${ID}_${clade}_${var_id}_nanosim" \\
    > "${sample_id}_${ID}_${clade}_${var_id}_outputsim.log" \\
    2> "${sample_id}_${ID}_${clade}_${var_id}_errorsim.log"

    # Find the aligned reads file and check if it exists before copying
    ALIGNED_FILE=\$(find . -name "${sample_id}_${ID}_${clade}_${var_id}_nanosim*aligned*reads.fastq" | head -n 1)
    
    if [ -n "\$ALIGNED_FILE" ] && [ -f "\$ALIGNED_FILE" ]; then
        # Compress the file with gzip and save directly to the target filename
        gzip -c "\$ALIGNED_FILE" > "${sample_id}_${ID}_${clade}_${var_id}_aligned_reads.fastq.gz"
        echo "Compressed \$ALIGNED_FILE to ${sample_id}_${ID}_${clade}_${var_id}_aligned_reads.fastq.gz" >> "${sample_id}_${ID}_${clade}_${var_id}_outputsim.log"
    else
        echo "ERROR: Could not find aligned reads file" >&2
        echo "Files in working directory:" >&2
        find . -type f -name "*.fastq" >&2
        exit 1
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nanosim_simulation: NanoSim 3.2.2
    END_VERSIONS
    """
}
