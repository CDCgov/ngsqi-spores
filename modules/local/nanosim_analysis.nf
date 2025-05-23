process READANALYSIS {
   container "${projectDir}/third_party/nanosim.sif"

   input:
   tuple val(reference), path(ref_path), path(alt_reference), val(sample_id), path(shortened_fastq)
    
   output:
   tuple val(sample_id), val(reference), path("${sample_id}_${reference}_model"), val("${sample_id}_${reference}_model/${sample_id}_${reference}_error"), emit: model_dir
   path "${sample_id}_${reference}_model/**", emit: all_model_files
   path "${sample_id}_${reference}*.log", emit: log_files
   path "versions.yml", emit: versions
   
   script:
   """
   # NanoSim read analysis
   read_analysis.py genome \
      -t 12 \
      -i "${shortened_fastq}" \
      -rg "${alt_reference}" \
      --fastq \
      -o "${sample_id}_${reference}_model/${sample_id}_${reference}_error"  \
      > "${sample_id}_${reference}_outputaln.log" \
      2> "${sample_id}_${reference}_erroraln.log"

   cat <<-END_VERSIONS > versions.yml
   "${task.process}":
        nanosim_readanalysis: NanoSim 3.2.2
   END_VERSIONS
   """
}