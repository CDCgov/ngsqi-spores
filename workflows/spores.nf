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
include { QC } from '../subworkflows/local/qc'
include { PREPROCESSING } from '../subworkflows/local/preprocessing'
include { QC as QC_CLEAN } from '../subworkflows/local/qc'
include { EXTRACT_READ_COUNT } from '../modules/local/extract_read_count.nf'
include { VARIANT_CALLING } from '../subworkflows/local/variant'
include { VARIANT_ANNOTATION } from '../subworkflows/local/variant_ann'
include { PHYLOGENY_PREP } from '../subworkflows/local/phylogeny_prep'
include { SIMULATION } from '../subworkflows/local/simulation'
include { QC as QC_SIM } from '../subworkflows/local/qc'
include { VARIANT_CALLING as VARIANT_SIM } from '../subworkflows/local/variant'
include { VARIANT_ANNOTATION as VARIANT_ANN_SIM } from '../subworkflows/local/variant_ann'


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
def checkPathParamList = [ params.input, params.fastas, params.download_script, params.altreference_script ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }
if (params.fastas) { ch_fastas = file(params.fastas) } else { exit 1, 'Reference genome not specified!' }
if (params.ncbi_email) { ncbi_email = params.ncbi_email } else { exit 1, 'NCBI email not specified!' }
if (params.ncbi_api_key) { ncbi_api_key = params.ncbi_api_key } else { exit 1, 'NCBI API Key not specified!' }
if (params.snpeff_db_dir) { snpeff_db_dir = params.snpeff_db_dir } else { exit 1, 'SnpEff database not specified!' }
if (params.snpeff_config) { snpeff_config = params.snpeff_config } else { exit 1, 'SnpEff config not specified!' }

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

    VALIDATE_FASTAS (file(ch_fastas), params.download_script, params.ncbi_email, params.ncbi_api_key)
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
                                EXTRACT READ COUNT
    ================================================================================
    */
    EXTRACT_READ_COUNT(nanostats)
    read_counts = EXTRACT_READ_COUNT.out.read_counts
/*
    ================================================================================
                                VARIANT DETECTION
    ================================================================================
    */
    VARIANT_CALLING(trimmed,fastas)
    ch_versions = ch_versions.mix(VARIANT_CALLING.out.versions)
/*
    ================================================================================
                                VARIANT ANNOTATION
    ================================================================================
    */
    VARIANT_ANNOTATION(VARIANT_CALLING.out.medaka_variants,params.snpeff_db_dir,params.snpeff_config)
    ch_versions = ch_versions.mix(VARIANT_ANNOTATION.out.versions)
/*
    ================================================================================
                                PHYLOGENY PREPARATION
    ================================================================================
    */
    PHYLOGENY_PREP(VARIANT_CALLING.out.medaka_variants,VARIANT_CALLING.out.meta_fasta_only)
    ch_versions = ch_versions.mix(VARIANT_CALLING.out.versions)
/*
    ================================================================================
                                Simulation
    ================================================================================
    */
    SIMULATION(fastas, trimmed,  params.altreference_script, read_counts)
    ch_versions = ch_versions.mix(SIMULATION.out.versions)
/*
    ================================================================================
                                Quality Control - Simulation
    ================================================================================
    */
    QC_SIM(SIMULATION.out.simulated_reads)
    ch_versions = ch_versions.mix(QC_SIM.out.versions)
/*
    ================================================================================
                                PostSim
    ================================================================================
    */
    VARIANT_SIM(SIMULATION.out.simulated_reads,fastas)
    ch_versions = ch_versions.mix(VARIANT_SIM.out.versions)
    medaka_variants_sim = VARIANT_SIM.out.medaka_variants

    VARIANT_ANN_SIM(medaka_variants_sim,params.snpeff_db_dir,params.snpeff_config)
    ch_versions = ch_versions.mix(VARIANT_ANN_SIM.out.versions)
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
