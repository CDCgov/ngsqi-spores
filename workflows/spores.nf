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
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//ch_multiqc_config          = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
//ch_multiqc_custom_config   = params.multiqc_config ? Channel.fromPath( params.multiqc_config, checkIfExists: true ) : Channel.empty()
//ch_multiqc_logo            = params.multiqc_logo   ? Channel.fromPath( params.multiqc_logo, checkIfExists: true ) : Channel.empty()
//ch_multiqc_custom_methods_description = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)

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
include { SIMULATION } from '../subworkflows/local/simulation'
include { QCSIM } from '../subworkflows/local/qcsim'


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
    fastas = VALIDATE_FASTAS.out.ref_path.view()
    ref_fastas = VALIDATE_FASTAS.out.ref_fastas

/*
    ================================================================================
                                Quality Control
    ================================================================================
    */
    QC (reads)
    ch_versions = ch_versions.mix(QC.out.versions)

/*
    ================================================================================
                                Preprocessing
    ================================================================================
    */
    PREPROCESSING(reads)
    trimmed = PREPROCESSING.out.trimmed.view()
    ch_versions = ch_versions.mix(PREPROCESSING.out.versions)
/*
    ================================================================================
                                Reference Preparation
    ================================================================================
    */
    REF_PREP ( ref_fastas )
    ch_versions = ch_versions.mix(REF_PREP.out.versions)

/*
    ================================================================================
                                Simulation
    ================================================================================
    */
    SIMULATION(fastas, trimmed,  params.altreference_script, QC.out.read_counts)
    ch_versions = ch_versions.mix(SIMULATION.out.versions)
/*
    ================================================================================
                                PostSim
    ================================================================================
    */
    QCSIM (SIMULATION.out.simulated_reads)
    ch_versions = ch_versions.mix(QCSIM.out.versions)
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
