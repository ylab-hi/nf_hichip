#!/usr/bin/env nextflow

process PAIRTOOLS_SORT {
    tag "$sample"
    
    container "https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/59/591e43b4619c63ff4c5dac3f7f4e1c34883235f16423bc3a6b0821adefe96fea/data"
    
    cpus 8
    memory '8.GB'
    time '24.h'

    
    publishDir "${params.outdir}/pairtools/sort", mode: 'copy'

    input:
    tuple val(sample), path(pairfile), val(condition)
    
    output:
    tuple val(sample), path("${sample}_parsed_sorted.pairs"), val(condition), emit: sorted
    
    script:
    """
    pairtools sort --nproc ${task.cpus} -o ${sample}_parsed_sorted.pairs ${pairfile}
    """
}