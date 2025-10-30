/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//include { INPUT_CHECK    } from '../subworkflows/local/input_check'
include { FASTQC } from '../modules/local/fastqc'
include { BWA } from '../modules/local/bwa'
include { FASTP } from '../modules/local/fastp'
include { PAIRTOOLS_PARSE } from '../modules/local/pairtools_parse'
include { PAIRTOOLS_SORT } from '../modules/local/pairtools_sort'
include { PAIRTOOLS_DEDUP } from '../modules/local/pairtools_dedup'
include { JUICER_PRE } from '../modules/local/juicer_pre'
include { HICEXP_CONVERT } from '../modules/local/hicexp_convert'

workflow HICHIP_WORKFLOW {
    

    main:
    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        CREATE CHANNELS FROM INPUT
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
     
    // Read and validate input samplesheet
    //INPUT_CHECK (
    //    file(params.input)
    //)

    // create input channels from samplesheet
    read_ch = Channel.fromPath(params.input)
        .splitCsv(header:true)
        .map { row -> [row.sample_id, file(row.fastq_1), file(row.fastq_2), row.condition] }
    
    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        MAIN WORKFLOW LOGIC
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    // Run FastQC on input reads
    FASTQC(read_ch)

    // Run fastp
    FASTP(read_ch)

    // Run BWA alignment
    // Get the directory containing the index file and stage all files
    bwa_index_dir = file(params.bwa_index).parent
    bwa_index_files = files("${bwa_index_dir}/*")

    BWA(FASTP.out.trimmed_reads, bwa_index_files)

    // run pairtools parse
    PAIRTOOLS_PARSE(BWA.out.bam, file(params.chroms_file))

    //run pairtools sort
    PAIRTOOLS_SORT(PAIRTOOLS_PARSE.out.parsed)

    //run pairtools dedup
    PAIRTOOLS_DEDUP(PAIRTOOLS_SORT.out.sorted)

    // run juicer pre to create .hic file
    JUICER_PRE(PAIRTOOLS_DEDUP.out.pairs)

    // run hicexp_convert to create cool file
    HICEXP_CONVERT(JUICER_PRE.out.hic)

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        COLLECT OUTPUTS
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    
    //emit:
    //results = EXAMPLE_MODULE.out.results
}