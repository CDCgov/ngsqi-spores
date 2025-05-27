process SHORTENHEADERS {
   container "${projectDir}/third_party/nanosim.sif"

   input:
   tuple val(reference), path(ref_path), path(alt_reference), val(sample_id), path(fastq)
    
   output:
   tuple val(reference), path(ref_path), path(alt_reference), val(sample_id), path("${sample_id}_shortened.fastq"), emit: shortened_fastq
   
   script:
   """
   # Create a file with shortened headers
   gunzip -c "${fastq}" | awk '{if(NR % 4 == 1 || NR % 4 == 3) {sub(/ .*/,""); print} else print}' > "${sample_id}_shortened.fastq"
   """
}