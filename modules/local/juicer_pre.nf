#!/usr/bin/env nextflow

process JUICER_PRE {
    tag "$sample"
    
    container "containers/juicer-1.6.sif"
    
    cpus 2
    memory '16.GB'
    time '24.h'

    
    publishDir "${params.outdir}/juicer/pre", mode: 'copy'

    input:
    tuple val(sample), path(pairfile), val(condition)
    
    output:
    tuple val(sample), path("${sample}.hic"), val(condition), emit: hic

    script:
    """
    juicer_tools pre \
        -k VC,VC_SQRT,KR,SCALE \
        ${pairfile} \
        ${sample}.hic \
        hg38
    """
}
