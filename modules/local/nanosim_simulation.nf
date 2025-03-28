process NANOSIMSIMULATION {
   publishDir "${params.outdir}", mode: 'copy'
   errorStrategy 'ignore'
   tag "sample: ${sample_id}"

   input:
   tuple val(sample_id), val(fastq), val(alt_reference), val(error_model)

   output:
   tuple val(sample_id), val(fastq), val(alt_reference), val(error_model), path("${alt_reference}_${error_model}_nanosim")
   //path "versions.yml", emit: versions
   
   script:
   """
   simulator.py genome \
      -rg "${alt_reference}" \
      -c "${error_model}" \
      -n 500000 \
      -t 9 \
      --fastq \
      -o "${alt_reference}_${error_model}_nanosim"

   //cat <<- 'END_VERSIONS' > versions.yml
   //"${task.process}":
   //   RAGTAG/SCAFFOLD: 2.1.0
   //END_VERSIONS
   """
}
