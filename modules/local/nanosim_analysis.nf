process READANALYSIS {
    container "${projectDir}/third_party/nanosim.sif"
    
    input:
    tuple val(sample_id), val(ref_id), path(shortened_fastq), val(clade), val(var_id), path(alt_ref_path)

    output:
    tuple val(sample_id), val(ref_id), path("model_dir"), val("${sample_id}_${ref_id}_error"), val(clade), val(var_id), emit: model_dir
    path "${sample_id}_${ref_id}_model/**", emit: all_model_files
    path "${sample_id}_${ref_id}*.log", emit: log_files
    path "versions.yml", emit: versions
   
    script:
    """
    # Initialize conda and activate the environment that should be in the container
    eval "\$(conda shell.bash hook)"
    conda activate nanosim

    mkdir -p "${sample_id}_${ref_id}_model"

    read_analysis.py genome \\
      -t 12 \\
      -i "${shortened_fastq}" \\
      -rg "${alt_ref_path}" \\
      --fastq \\
      -o "${sample_id}_${ref_id}_model/${sample_id}_${ref_id}_error" \\
      > "${sample_id}_${ref_id}_outputaln.log" \\
      2> "${sample_id}_${ref_id}_erroraln.log"

    # Create symlink for expected output
    ln -s "${sample_id}_${ref_id}_model" model_dir

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
      nanosim_readanalysis: NanoSim 3.2.2
    END_VERSIONS
    """
}