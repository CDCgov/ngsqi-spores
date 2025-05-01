process NANOSIMSIMULATION {
   container "/scicomp/home-pure/xvp4/spores/third_party/nanosim.sif"
   publishDir "${params.outdir}", mode: 'copy'
   errorStrategy 'ignore'
   tag "sample: ${sample_id}"

   input:
   tuple val(sample_id), val(reference_id), path(model_dir)
   tuple val(sample_id), val(reference_id), val(model_prefix)
   tuple val(reference_id), val(ref_file), path(alt_reference)

   output:
   path "${sample_id}_${reference_id}_nanosim*", emit: nanosim_output
   path "${sample_id}_${reference_id}*.log", emit: log_files
   
   script:
   """
   # Debug information
   echo "Starting simulation for ${sample_id} against ${reference_id}"
   echo "Current directory: \$(pwd)"
   echo "Model directory contents:"
   ls -la "${model_dir}"
   echo "Model prefix: ${model_prefix}"
   
   # Run simulator.py
   simulator.py genome \
      -rg "${alt_reference}" \
      -c "${model_prefix}" \
      -n 2513550 \
      -t 9 \
      --fastq \
      -o "${sample_id}_${reference_id}_nanosim" \
      > "${sample_id}_${reference_id}_outputsim.log" \
      2> "${sample_id}_${reference_id}_errorsim.log"
   """
}