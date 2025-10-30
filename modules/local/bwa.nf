#!/usr/bin/env nextflow

process BWA {
    tag "$sample"
    container "https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/03/036fd8e0b8304d3f3d01d75f5ae087a45fc8e91a55c60bd9677542301d574738/data"

    label 'process_high'
    
    publishDir "${params.outdir}/bwa_aligned", mode: 'copy'

    input:
    tuple val(sample), path(read1), path(read2), val(condition)
    path(bwa_index)

    output:
    tuple val(sample), path("${sample}.bam"), val(condition), emit: bam

    script:
    def index_base = file(params.bwa_index).name
    """
    bwa mem \\
        -5SP \\
        -t ${task.cpus} \\
        ${index_base} \\
        ${read1} ${read2} | \\
    samtools view -bS - > ${sample}.bam
    """

    stub:
    """
    touch ${sample}.bam
    """
}