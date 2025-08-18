/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PRINT PARAMS SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { paramsSummaryLog; paramsSummaryMap } from 'plugin/nf-validation'

def logo = NfcoreTemplate.logo(workflow, params.monochrome_logs)
def citation = '\n' + WorkflowMain.citation(workflow) + '\n'
def summary_params = paramsSummaryMap(workflow)

// Print parameter summary log to screen
log.info logo + paramsSummaryLog(workflow) + citation

WorkflowSpores.initialise(params, log)
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { INPUT_CHECK } from '../subworkflows/local/input_check'
include { VALIDATE_FASTAS } from '../subworkflows/local/validate_fastas'
include { REF_PREP } from '../subworkflows/local/ref_prep'
include { QC } from '../subworkflows/local/qc'
include { PREPROCESSING } from '../subworkflows/local/preprocessing'
include { QC as QC_CLEAN } from '../subworkflows/local/qc'
include { EXTRACT_READ_COUNT } from '../modules/local/extract_read_count.nf'
include { VARIANT_CALLING } from '../subworkflows/local/variant'
include { PHYLOGENY_ESTIMATION } from '../subworkflows/local/phylogeny_estimation.nf'
include { VARIANT_ANNOTATION } from '../subworkflows/local/variant_ann'
include { PHYLOGENY_PREP } from '../subworkflows/local/phylogeny_prep'
include { SIMULATION } from '../subworkflows/local/simulation'
include { QC as QC_SIM } from '../subworkflows/local/qc'
include { VARIANT_CALLING as VARIANT_SIM } from '../subworkflows/local/variant'
include { VARIANT_ANNOTATION as VARIANT_ANN_SIM } from '../subworkflows/local/variant_ann'
include { PHYLOGENY_PREP as PHYLOGENY_PREP_SIM } from '../subworkflows/local/phylogeny_prep'
include { PHYLOGENY_ESTIMATION as PHYLOGENY_SIM } from '../subworkflows/local/phylogeny_estimation.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/custom/dumpsoftwareversions/main'

/*
    ================================================================================
                                Validate Inputs
    ================================================================================
    */

// Check input path parameters to see if they exist
def checkPathParamList = [ params.input, params.fastas, params.download_script, params.download_script_single, params.altreference_script, params.vcf2phylip_script ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }
if (params.fastas) { ch_fastas = file(params.fastas) } else { exit 1, 'Reference samplesheet not specified!' }
if (params.reference_genome) { reference_genome = params.reference_genome } else { exit 1, 'Reference genome not specified!' }
if (params.postsim && !params.simulation) { exit 1, "--postsim cannot be used without enabling --simulation. Please set --simulation to true." }
if (params.ncbi_email) { ncbi_email = params.ncbi_email } else { exit 1, 'NCBI email not specified!' }
if (params.ncbi_api_key) { ncbi_api_key = params.ncbi_api_key } else { exit 1, 'NCBI API Key not specified!' }
if (params.snpeffdb) { snpeffdb = params.snpeffdb } else { exit 1, 'SnpEff database not specified!' }
if (params.snpeffconf) { snpeffconf = params.snpeffconf } else { exit 1, 'SnpEff config not specified!' }

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


workflow SPORES {

    ch_versions = Channel.empty()

/*
    ================================================================================
                                Samplesheet Validation
    ================================================================================
    */
    INPUT_CHECK (file(params.input))
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)
    reads = INPUT_CHECK.out.reads

    VALIDATE_FASTAS (file(ch_fastas), reference_genome, params.download_script, params.download_script_single, ncbi_email, ncbi_api_key)
    ch_versions = ch_versions.mix(VALIDATE_FASTAS.out.versions)
    fastas = VALIDATE_FASTAS.out.ref_path
    ref_fastas = VALIDATE_FASTAS.out.ref_fastas

/*
    ================================================================================
                            Quality Control - Raw
    ================================================================================
    */

    QC(reads)
    ch_versions = ch_versions.mix(QC.out.versions)

/*
    ================================================================================
                                Preprocessing
    ================================================================================
    */
    PREPROCESSING(reads)
    trimmed = PREPROCESSING.out.trimmed
    ch_versions = ch_versions.mix(PREPROCESSING.out.versions)

/*
    ================================================================================
                            Quality Control - Trimmed
    ================================================================================
    */
    QC_CLEAN(trimmed)
    nanostats = QC_CLEAN.out.nanostats
    ch_versions = ch_versions.mix(QC_CLEAN.out.versions)

/*
    ================================================================================
                                Extract Read Count
    ================================================================================
    */
    EXTRACT_READ_COUNT(nanostats)
    read_counts = EXTRACT_READ_COUNT.out.read_counts
/*
    ================================================================================
                                Reference Preparation
    ================================================================================
    */
    REF_PREP(VALIDATE_FASTAS.out.ref_genome)
    fai = REF_PREP.out.fai
    masked = REF_PREP.out.masked
    ch_versions = ch_versions.mix(REF_PREP.out.versions)

/*
    ================================================================================
                            Variant Calling and Annotation
    ================================================================================
    */
    VARIANT_CALLING(trimmed, masked, fai)
    medaka_variants = VARIANT_CALLING.out.medaka_variants
    ch_versions = ch_versions.mix(VARIANT_CALLING.out.versions)

/*
    ================================================================================
                                VARIANT ANNOTATION
    ================================================================================
    */
    VARIANT_ANNOTATION(medaka_variants, snpeffdb, snpeffconf)
    ch_versions = ch_versions.mix(VARIANT_ANNOTATION.out.versions)
/*
    ================================================================================
                                Phylogeny Estimation
    ================================================================================
    */
    PHYLOGENY_PREP(medaka_variants, VARIANT_CALLING.out.masked_fai, params.vcf2phylip_script)
    multi_fasta_snps = PHYLOGENY_PREP.out.multi_fasta_snps
    ch_versions = ch_versions.mix(VARIANT_CALLING.out.versions)

    compress= false

    PHYLOGENY_ESTIMATION(multi_fasta_snps, compress)
    ch_versions = ch_versions.mix(PHYLOGENY_ESTIMATION.out.versions)
/*
    ================================================================================
                                    Simulation
    ================================================================================
    */
    if (params.simulation) {
    SIMULATION(fastas, trimmed,  params.altreference_script, read_counts)
    simulated_reads = SIMULATION.out.simulated_reads
    ch_versions = ch_versions.mix(SIMULATION.out.versions)

/*
    ================================================================================
                                Quality Control - Simulation
    ================================================================================
    */
    QC_SIM(simulated_reads)
    ch_versions = ch_versions.mix(QC_SIM.out.versions)
    }
/*
    ================================================================================
                    Variant Calling and Annotation - Simulation
    ================================================================================
    */
    if (params.postsim) {
    VARIANT_SIM(simulated_reads, masked, fai)
    ch_versions = ch_versions.mix(VARIANT_SIM.out.versions)
    medaka_variants_sim = VARIANT_SIM.out.medaka_variants

    VARIANT_ANN_SIM(medaka_variants_sim, snpeffdb, snpeffconf)
    ch_versions = ch_versions.mix(VARIANT_ANN_SIM.out.versions)

/*
    ================================================================================
                            Phylogeny Estimation - Simulation
    ================================================================================
    */
    PHYLOGENY_PREP_SIM(medaka_variants_sim, VARIANT_SIM.out.masked_fai, params.vcfSnpsToFasta_script)
    ch_versions = ch_versions.mix(PHYLOGENY_PREP_SIM.out.versions)
    multi_fasta_snps_sim = PHYLOGENY_PREP_SIM.out.multi_fasta_snps

    PHYLOGENY_SIM(multi_fasta_snps_sim, compress)
    ch_versions = ch_versions.mix(PHYLOGENY_SIM.out.versions)
    }
/*
    ================================================================================
                                Versions Report
    ================================================================================
    */
    ch_versions_unique = ch_versions.unique()
    CUSTOM_DUMPSOFTWAREVERSIONS(ch_versions_unique.collectFile(name: 'collated_versions.yml'))

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report)
    }
    NfcoreTemplate.dump_parameters(workflow, params)
    NfcoreTemplate.summary(workflow, params, log)
    if (params.hook_url) {
        NfcoreTemplate.IM_notification(workflow, params, summary_params, projectDir, log)
    }
}

workflow.onError {
    if (workflow.errorReport.contains("Process requirement exceeds available memory")) {
        println("🛑 Default resources exceed availability 🛑 ")
        println("💡 See here on how to configure pipeline: https://nf-co.re/docs/usage/configuration#tuning-workflow-resources 💡")
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
