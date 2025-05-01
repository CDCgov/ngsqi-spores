process READANALYSIS {
   container "/scicomp/home-pure/xvp4/spores/third_party/nanosim.sif"
   publishDir "${params.outdir}", mode: 'copy'
   errorStrategy 'ignore'

   input:
   tuple val(sample_id), path(fastq), val(reference_id), path(ref_file), path(alt_reference)
    

   output:
   tuple val(sample_id), val(reference_id), path("${sample_id}_${reference_id}_model"), emit: model_dir
   tuple val(sample_id), val(reference_id), val("${sample_id}_${reference_id}_model/${sample_id}_${reference_id}_error"), emit: model_prefix
   path "${sample_id}_${reference_id}_model/**", emit: all_model_files
   path "${sample_id}_${reference_id}*.log", emit: log_files
   
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
      -o "${sample_id}_${reference_id}_model/${sample_id}_${reference_id}_error"  \
      > "${sample_id}_${reference_id}_outputaln.log" \
      2> "${sample_id}_${reference_id}_erroraln.log"
   
   # Clean up 
   rm -f shortened.fastq
   """
}