process NANOSIMSIMULATION {
   container "/scicomp/home-pure/xvp4/spores/third_party/nanosim.sif"
   publishDir "${params.outdir}", mode: 'copy'
   errorStrategy 'ignore'
   tag "sample: ${sample_id} ref: ${ID}"

   input:
   tuple val(sample_id), val (reference), path(model_dir), val(model_prefix), val(ID), path(ref_file), path(alt_ref)

   output:
   path "${sample_id}_${ID}_nanosim*", emit: nanosim_output
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

   cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nanosim: \$(echo \$(nanosim --version 2>&1) | sed 's/^.*nanosim //; s/Using.*\$//')
    END_VERSIONS
   """
}