process NANOSIM_ANALYSIS {
   publishDir "${params.outdir}", mode: 'copy'
   errorStrategy 'ignore'
   tag "sample: ${sample_id}"

   input:
   tuple val(sample_id), val(added_copy_number), val(iso_file_path), val(species_name), val(ref_accession), path(ref_genome), path(scaff_dir)

   output:
   tuple val(sample_id), val(added_copy_number), path("patched_${sample_id}"), val(species_name), val(ref_accession), path(ref_genome), emit: ragtag_patch_dirs optional true
   path "versions.yml", emit: versions
   
   script:
   """


   //cat <<- 'END_VERSIONS' > versions.yml
   //"${task.process}":
   //   RAGTAG/SCAFFOLD: 2.1.0
   //END_VERSIONS
   """
}
