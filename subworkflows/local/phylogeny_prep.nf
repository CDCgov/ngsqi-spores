/*
========================================================================================
    PHYLOGENY PREPARATION
========================================================================================
*/
include { BCFTOOLS_SORT } from '../../modules/nf-core/bcftools/sort/main'
include { BCFTOOLS_MERGE } from '../../modules/nf-core/bcftools/merge/main'
include { BCFTOOLS_CONSENSUS } from '../../modules/nf-core/bcftools/consensus/main'
include { BCFTOOLS_VIEW } from '../../modules/nf-core/bcftools/view/main'
include { COMBINE_CONSENSUS } from '../../modules/local/multi_fasta'
include { VCF2PHYLIP } from '../../modules/local/vcf2phylip'

workflow PHYLOGENY_PREP {
    take:
    medaka_variants
    fastas
    vcf2phylip_script

    main:
    ch_versions = Channel.empty()

    vcf2phylip_script = Channel.fromPath(params.vcf2phylip_script)

    // Sort VCF files
    BCFTOOLS_SORT(medaka_variants)
    ch_versions = ch_versions.mix(BCFTOOLS_SORT.out.versions)

    // Extract clade 1 reference
    reference_fasta = fastas
        .filter { reference, clade, var_id, chrom, pos, var_seq, fasta_file ->
            clade == "1"
        }
        .map { reference, clade, var_id, chrom, pos, var_seq, fasta_file ->
            fasta_file
        }

    // Get single reference fasta for consistent use
    single_fasta = reference_fasta.first()

    // CONSENSUS WORKFLOW
    individual_consensus_inputs = BCFTOOLS_SORT.out.vcf
        .join(BCFTOOLS_SORT.out.tbi, by: 0)
        .combine(reference_fasta)
        .map { meta, vcf, tbi, fasta ->
            [meta, vcf, tbi, fasta]
        }

    //BCFTOOLS_CONSENSUS(individual_consensus_inputs)
    //ch_versions = ch_versions.mix(BCFTOOLS_CONSENSUS.out.versions)

    //consensus_files = BCFTOOLS_CONSENSUS.out.fasta
    //    .map { meta, fasta -> fasta }
    //    .collect()
    //    .map { files ->
    //        def meta = [id: 'all_samples_consensus']
    //        [meta, files]
    //    }

    //COMBINE_CONSENSUS(consensus_files)

    // VCF WORKFLOW
    
    vcf_tbi_with_meta = BCFTOOLS_SORT.out.vcf
        .join(BCFTOOLS_SORT.out.tbi, by: 0)
        .toList()
        .map { list_of_items ->
            def all_vcfs = list_of_items.collect { meta, vcf, tbi -> vcf }
            def all_tbis = list_of_items.collect { meta, vcf, tbi -> tbi }
            def merge_meta = [id: 'merged_samples'] 
            [merge_meta, all_vcfs, all_tbis]
        }
    
    ref_tuple = single_fasta.map { fasta -> [[id: 'reference'], fasta] }

    BCFTOOLS_MERGE(vcf_tbi_with_meta, ref_tuple)
    ch_versions = ch_versions.mix(BCFTOOLS_MERGE.out.versions)

    VCF2PHYLIP(BCFTOOLS_MERGE.out.vcf_with_index, vcf2phylip_script)
    ch_versions = ch_versions.mix(VCF2PHYLIP.out.versions)

    emit:
    //individual_consensus = BCFTOOLS_CONSENSUS.out.fasta
    //multi_fasta_consensus = COMBINE_CONSENSUS.out.multi_fasta
    //multi_fasta = COMBINE_CONSENSUS.out.multi_fasta
    
    // VCF-based outputs
    multi_vcf = BCFTOOLS_MERGE.out.vcf_with_index
    multi_fasta_snps = VCF2PHYLIP.out.fasta
    
    versions = ch_versions
}