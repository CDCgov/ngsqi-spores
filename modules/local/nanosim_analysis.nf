process READANALYSIS {
   container "${projectDir}/third_party/nanosim.sif"

   input:
   tuple val(reference), path(ref_path), path(alt_reference), val(sample_id), path(fastq)
    
   output:
   tuple val(sample_id), val(reference), path("${sample_id}_${reference}_model"), val("${sample_id}_${reference}_model/${sample_id}_${reference}_error"), emit: model_dir
   path "${sample_id}_${reference}_model/**", emit: all_model_files
   path "${sample_id}_${reference}*.log", emit: log_files
   path "versions.yml", emit: versions
   
   script:
   """
   # Create a temporary file with shortened headers
   gunzip -c "${fastq}" | awk '{if(NR % 4 == 1 || NR % 4 == 3) {sub(/ .*/,""); print} else print}' > shortened.fastq
   
   # NanoSim read analysis
   read_analysis.py genome \
      -t 12 \
      -i shortened.fastq \
      -rg "${alt_reference}" \
      --fastq \
      -o "${sample_id}_${reference}_model/${sample_id}_${reference}_error"  \
      > "${sample_id}_${reference}_outputaln.log" \
      2> "${sample_id}_${reference}_erroraln.log"
   
   # Clean up 
   rm -f shortened.fastq

   cat <<-END_VERSIONS > versions.yml
   "${task.process}":
        nanosim_readanalysis: NanoSim 3.2.2
   END_VERSIONS
   """
}