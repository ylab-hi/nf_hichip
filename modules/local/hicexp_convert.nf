#!/usr/bin/env nextflow

process HICEXP_CONVERT {
    tag "$sample"
    
    container "https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/0b/0b8ba4db33c607a363fd8373e9d54ca2d8c9b0bb593aa40b32cc009f14b5db0e/data"
    
    cpus 1
    memory '8.GB'
    time '8.h'

    
    publishDir "${params.outdir}/hicexplorer/convert", mode: 'copy'

    input:
    tuple val(sample), path(hic_file), val(condition)
    
    output:
    tuple val(sample), path("${sample}.mcool"), val(condition)

    script:
    """
    hicConvertFormat -m ${hic_file} \
        --inputFormat hic \
        --outputFormat cool \
        --outFileName ${sample}.mcool
    """
}
