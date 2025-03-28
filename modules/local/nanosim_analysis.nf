process READANALYSIS {
   publishDir "${params.outdir}", mode: 'copy'
   errorStrategy 'ignore'
   tag "sample: ${sample_id}"

   input:
   tuple val(sample_id), val(fastq)
   tuple val(reference_id), val(ref_file), val(alt_reference)

   output:
   tuple val(sample_id), val(fastq), val(alt_reference), path("${fastq}_${alt_reference}_error_model_fq"), emit:nanosim_model
   
   script:
   """
   read_analysis.py genome \
      -t 12 \
      -i "${fastq}" \
      -rg "${alt_reference}" \
      --fastq \
      -o "${fastq}_${alt_reference}_error_model_fq"

   //cat <<- 'END_VERSIONS' > versions.yml
   //"${task.process}":
   //   RAGTAG/SCAFFOLD: 2.1.0
   //END_VERSIONS
   """
}
